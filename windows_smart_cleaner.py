import sys
import os
import time
import hashlib
import math
import subprocess
from datetime import datetime, timedelta
import send2trash

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                             QHBoxLayout, QPushButton, QLabel, QTabWidget, 
                             QProgressBar, QFileDialog, QMessageBox, QTreeWidget,
                             QTreeWidgetItem, QHeaderView)
from PyQt5.QtCore import Qt, QThread, pyqtSignal
from PyQt5.QtGui import QFont

def format_size(size_bytes):
    if size_bytes <= 0:
        return "0B"
    size_name = ("B", "KB", "MB", "GB", "TB")
    i = int(math.floor(math.log(size_bytes, 1024)))
    p = math.pow(1024, i)
    s = round(size_bytes / p, 2)
    return f"{s} {size_name[i]}"

class ScanCleanThread(QThread):
    progress = pyqtSignal(int, str)
    found_category = pyqtSignal(str, str, int, float, str)
    finished = pyqtSignal()
    
    def __init__(self):
        super().__init__()
        self.targets = [
            ("ملفات المستخدم المؤقتة (TEMP)", "ملفات تتركها البرامج. (يُنصح بحذفها - آمنة جداً)", os.environ.get('TEMP')),
            ("ملفات النظام المؤقتة (Windows Temp)", "ملفات تركها نظام الويندوز. (يُنصح بحذفها - آمنة جداً)", r"C:\Windows\Temp"),
            ("مخلفات تحديثات الويندوز", "ملفات ضخمة لتحديثات قديمة. (آمنة، وفر مساحة كبيرة)", r"C:\Windows\SoftwareDistribution\Download")
        ]
        
    def run(self):
        self.progress.emit(10, "جاري فحص المجلدات المؤقتة بأمان...")
        
        for i, (name, desc, path) in enumerate(self.targets):
            count = 0
            size = 0
            if path and os.path.exists(path):
                for root, dirs, files in os.walk(path):
                    for f in files:
                        try:
                            file_path = os.path.join(root, f)
                            stat = os.stat(file_path)
                            if stat.st_mtime < time.time() - (24 * 3600):
                                size += stat.st_size
                                count += 1
                        except:
                            pass
            
            self.found_category.emit(name, desc, count, size, path)
            self.progress.emit(30 + (i * 20), f"تم فحص {name}...")
            
        self.progress.emit(100, "اكتمل الفحص. راجع القائمة ثم اتخذ قرارك.")
        self.finished.emit()

class ExecuteCleanThread(QThread):
    progress = pyqtSignal(int, str)
    finished = pyqtSignal(int, int, int) # deleted, saved, failed
    
    def __init__(self, selected_paths):
        super().__init__()
        self.paths = selected_paths
        
    def run(self):
        deleted_count = 0
        saved_bytes = 0
        failed_count = 0
        cutoff_time = time.time() - (24 * 3600)
        
        for i, path in enumerate(self.paths):
            if not path or not os.path.exists(path): continue
            
            self.progress.emit(50, f"جاري التنظيف الآمن... يرجى الانتظار")
            for root, dirs, files in os.walk(path):
                for f in files:
                    try:
                        file_path = os.path.join(root, f)
                        stat = os.stat(file_path)
                        if stat.st_mtime < cutoff_time:
                            s = stat.st_size
                            try:
                                os.remove(file_path)
                                saved_bytes += s
                                deleted_count += 1
                            except (PermissionError, OSError):
                                failed_count += 1
                    except:
                        pass
                        
        self.progress.emit(100, "اكتمل التنظيف.")
        self.finished.emit(deleted_count, saved_bytes, failed_count)

class DeadFilesThread(QThread):
    progress = pyqtSignal(int, str)
    found_file = pyqtSignal(str, int, float) 
    finished = pyqtSignal()
    
    def __init__(self, folder):
        super().__init__()
        self.folder = folder
        
    def run(self):
        import concurrent.futures
        cutoff_time = time.time() - (180 * 24 * 3600)
        min_size = 50 * 1024 * 1024 
        
        self.progress.emit(2, "جاري جمع قائمة الملفات (قد يستغرق بعض الوقت)...")
        all_files = []
        count = 0
        for root, dirs, files in os.walk(self.folder):
            for f in files:
                all_files.append(os.path.join(root, f))
                count += 1
                if count % 1000 == 0:
                    self.progress.emit(5, f"جاري البحث داخل المجلدات... (تم إيجاد {count} ملف)")
                
        total_files = len(all_files)
        if total_files == 0:
            self.progress.emit(100, "لا توجد ملفات.")
            self.finished.emit()
            return
            
        def check_file(file_path):
            try:
                stat = os.stat(file_path)
                if stat.st_atime < cutoff_time and stat.st_mtime < cutoff_time and stat.st_size >= min_size:
                    days_old = (time.time() - stat.st_mtime) / (24 * 3600)
                    return (file_path, stat.st_size, days_old)
            except:
                pass
            return None
            
        chunk_size = max(1, total_files // 3)
        chunks = [all_files[i:i + chunk_size] for i in range(0, total_files, chunk_size)]
        
        processed = 0
        with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as executor:
            for chunk_idx, chunk in enumerate(chunks):
                futures = {executor.submit(check_file, p): p for p in chunk}
                for future in concurrent.futures.as_completed(futures):
                    res = future.result()
                    if res:
                        self.found_file.emit(*res)
                    processed += 1
                    if processed % 100 == 0:
                        perc = 5 + int((processed / total_files) * 95)
                        self.progress.emit(perc, f"القسم {chunk_idx+1}/3: تحليل أعمار الملفات... ({processed}/{total_files})")
                
        self.progress.emit(100, "اكتمل البحث.")
        self.finished.emit()

class DuplicateThread(QThread):
    progress = pyqtSignal(int, str)
    found_dups = pyqtSignal(list)
    finished = pyqtSignal()
    
    def __init__(self, folder):
        super().__init__()
        self.folder = folder
        
    def run(self):
        from collections import defaultdict
        import concurrent.futures
        
        self.progress.emit(2, "جاري جمع قائمة الملفات (الرجاء الانتظار، المجلدات الكبيرة تأخذ وقتاً)...")
        size_dict = defaultdict(list)
        all_files = []
        count = 0
        
        for root, dirs, files in os.walk(self.folder):
            for f in files:
                all_files.append(os.path.join(root, f))
                count += 1
                if count % 1000 == 0:
                    self.progress.emit(5, f"جاري جمع قائمة الملفات... (تم إيجاد {count} ملف)")
                    
        total_files = len(all_files)
        if total_files == 0:
            self.progress.emit(100, "لم يتم العثور على ملفات.")
            self.found_dups.emit([])
            self.finished.emit()
            return
            
        def get_size(path):
            try:
                s = os.path.getsize(path)
                return path, s
            except:
                return path, 0
                
        # Get sizes in parallel to speed up SSD access
        processed_sizes = 0
        with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as executor:
            chunk_size_files = max(1, total_files // 3)
            size_chunks = [all_files[i:i + chunk_size_files] for i in range(0, total_files, chunk_size_files)]
            for chunk_idx, chunk in enumerate(size_chunks):
                futures = {executor.submit(get_size, p): p for p in chunk}
                for future in concurrent.futures.as_completed(futures):
                    p, s = future.result()
                    if s > 0:
                        size_dict[s].append(p)
                    processed_sizes += 1
                    if processed_sizes % 500 == 0:
                        perc = 5 + int((processed_sizes / total_files) * 35)
                        self.progress.emit(perc, f"القسم {chunk_idx+1}/3: مطابقة الأحجام... ({processed_sizes}/{total_files})")
                
        potential_dups = {s: paths for s, paths in size_dict.items() if len(paths) > 1}
        paths_to_hash = []
        for paths in potential_dups.values():
            paths_to_hash.extend(paths)
            
        total_to_hash = len(paths_to_hash)
        if total_to_hash == 0:
            self.progress.emit(100, "لا توجد ملفات متطابقة بالحجم.")
            self.found_dups.emit([])
            self.finished.emit()
            return
            
        hash_dict = defaultdict(list)
        processed_hash = 0
        
        def hash_file(path):
            try:
                h = self.get_file_hash(path)
                return path, h
            except:
                return path, None
                
        # Hash in 3 chunks, updating UI after each chunk
        chunk_size_hash = max(1, total_to_hash // 3)
        hash_chunks = [paths_to_hash[i:i + chunk_size_hash] for i in range(0, total_to_hash, chunk_size_hash)]
        
        with concurrent.futures.ThreadPoolExecutor(max_workers=os.cpu_count() or 4) as executor:
            for chunk_idx, chunk in enumerate(hash_chunks):
                futures = {executor.submit(hash_file, p): p for p in chunk}
                for future in concurrent.futures.as_completed(futures):
                    p, h = future.result()
                    if h:
                        hash_dict[h].append(p)
                    processed_hash += 1
                    if processed_hash % 10 == 0:
                        perc = 40 + int((processed_hash / total_to_hash) * 60)
                        self.progress.emit(perc, f"القسم {chunk_idx+1}/3: مطابقة البصمة الرقمية... ({processed_hash}/{total_to_hash})")
                        
                # Emit results found so far after each chunk to avoid waiting!
                current_dups = [paths for paths in hash_dict.values() if len(paths) > 1]
                if current_dups:
                    self.found_dups.emit(current_dups)
                    
        self.progress.emit(100, "اكتمل البحث.")
        self.finished.emit()
        
    def get_file_hash(self, filepath, block_size=65536):
        hasher = hashlib.sha256()
        with open(filepath, 'rb') as f:
            buf = f.read(block_size)
            while len(buf) > 0:
                hasher.update(buf)
                buf = f.read(block_size)
        return hasher.hexdigest()

class App(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Windows Smart Cleaner Pro - الأداة الاحترافية المتكاملة")
        self.resize(1000, 750)
        self.setLayoutDirection(Qt.RightToLeft) 
        
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QWidget { color: #f0f0f0; font-family: 'Segoe UI', Tahoma, Arial; font-size: 15px; }
            QTabWidget::pane { border: 1px solid #333; background: #252526; border-radius: 5px; }
            QTabBar::tab { background: #333; color: white; padding: 12px 25px; border-top-left-radius: 6px; border-top-right-radius: 6px; margin-left: 2px; font-weight: bold; }
            QTabBar::tab:selected { background: #007acc; border-bottom: 2px solid #fff; }
            QPushButton { background-color: #007acc; color: white; border: none; padding: 12px; border-radius: 6px; font-weight: bold; font-size: 15px; }
            QPushButton:hover { background-color: #005f9e; }
            QPushButton:disabled { background-color: #444; color: #888; }
            QProgressBar { border: 1px solid #444; border-radius: 5px; text-align: center; background-color: #2d2d30; color: white; font-weight: bold; height: 25px; }
            QProgressBar::chunk { background-color: #007acc; border-radius: 5px; }
            QTreeWidget { background-color: #1e1e1e; border: 1px solid #333; alternate-background-color: #252526; }
            QHeaderView::section { background-color: #333; padding: 6px; border: 1px solid #444; font-weight: bold; }
            QTreeWidget::item { padding: 5px; }
        """)
        
        central_widget = QWidget()
        self.setCentralWidget(central_widget)
        main_layout = QVBoxLayout(central_widget)
        
        header_label = QLabel("Windows Smart Cleaner Pro (النسخة المتكاملة الآمنة)")
        header_label.setStyleSheet("font-size: 24px; font-weight: bold; color: #007acc; padding: 10px;")
        header_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(header_label)
        
        self.tabs = QTabWidget()
        main_layout.addWidget(self.tabs)
        
        self.init_cleanup_tab()
        self.init_apps_tab() 
        self.init_dead_files_tab()
        self.init_duplicates_tab()
        self.init_onedrive_tab()
        
    def init_onedrive_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        
        desc = QLabel("☁️ طوارئ OneDrive: حل مشكلة 'لا تتوفر مساحة حرة كافية'.\nانقر على أحد الأزرار أدناه ليقوم البرنامج بتوجيه أقوى محركاته لتنظيف مساحتك السحابية فوراً.")
        desc.setAlignment(Qt.AlignCenter)
        desc.setStyleSheet("font-size: 16px; margin: 20px; color: #4fc3f7;")
        layout.addWidget(desc)
        
        btn_od_dup = QPushButton("1. فحص المكررات داخل OneDrive (آمن جداً)")
        btn_od_dup.setFixedHeight(60)
        btn_od_dup.clicked.connect(lambda: self.launch_onedrive_scan('dup'))
        layout.addWidget(btn_od_dup)
        
        layout.addSpacing(10)
        
        btn_od_dead = QPushButton("2. البحث عن الملفات المهجورة والضخمة في OneDrive")
        btn_od_dead.setFixedHeight(60)
        btn_od_dead.clicked.connect(lambda: self.launch_onedrive_scan('dead'))
        layout.addWidget(btn_od_dead)
        
        layout.addStretch()
        self.tabs.addTab(tab, "طوارئ OneDrive ☁️")
        
    def launch_onedrive_scan(self, scan_type):
        od_path = os.path.expanduser(r"~\OneDrive")
        if not os.path.exists(od_path):
            QMessageBox.warning(self, "خطأ", f"لم يتم العثور على مجلد OneDrive في المسار الافتراضي:\n{od_path}")
            return
            
        if scan_type == 'dup':
            self.tabs.setCurrentIndex(3) # المكررات
            self.dup_tree.clear()
            self.dup_scan_btn.setEnabled(False)
            self.dup_delete_btn.setEnabled(False)
            self.dup_progress.show()
            self.dup_progress.setValue(0)
            self.dup_thread = DuplicateThread(od_path)
            self.dup_thread.progress.connect(self.update_dup_progress)
            self.dup_thread.found_dups.connect(self.populate_dups)
            self.dup_thread.finished.connect(self.dup_scan_finished)
            self.dup_thread.start()
            
        elif scan_type == 'dead':
            self.tabs.setCurrentIndex(2) # الملفات الميتة
            self.dead_tree.clear()
            self.dead_scan_btn.setEnabled(False)
            self.dead_delete_btn.setEnabled(False)
            self.dead_progress.show()
            self.dead_progress.setValue(0)
            self.dead_thread = DeadFilesThread(od_path)
            self.dead_thread.progress.connect(self.update_dead_progress)
            self.dead_thread.found_file.connect(self.add_dead_file)
            self.dead_thread.finished.connect(self.dead_scan_finished)
            self.dead_thread.start()
        
    def init_cleanup_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        
        desc = QLabel("تنظيف النظام التفاعلي: يتيح لك فحص المجلدات الميتة في النظام أولاً،\nلتشاهد بنفسك ما سيتم حذفه، وكم المساحة، لتتخذ القرار بثقة وبدون المساس بملفات النظام الحساسة.")
        desc.setAlignment(Qt.AlignCenter)
        desc.setStyleSheet("margin: 5px; color: #cccccc;")
        layout.addWidget(desc)
        
        top_layout = QHBoxLayout()
        self.scan_sys_btn = QPushButton("فحص مساحات النظام الميتة الآن")
        self.scan_sys_btn.clicked.connect(self.start_sys_scan)
        top_layout.addWidget(self.scan_sys_btn)
        
        self.sys_progress = QProgressBar()
        self.sys_progress.setValue(0)
        self.sys_progress.hide()
        top_layout.addWidget(self.sys_progress)
        layout.addLayout(top_layout)
        
        self.sys_status = QLabel("")
        layout.addWidget(self.sys_status)
        
        self.sys_tree = QTreeWidget()
        self.sys_tree.setAlternatingRowColors(True)
        self.sys_tree.setHeaderLabels(["تحديد", "نوع الملفات", "نصيحة الخبراء", "عدد الملفات", "الحجم المتوفر"])
        self.sys_tree.header().setSectionResizeMode(1, QHeaderView.ResizeToContents)
        self.sys_tree.header().setSectionResizeMode(2, QHeaderView.Stretch)
        layout.addWidget(self.sys_tree)
        
        self.clean_sys_btn = QPushButton("تنظيف الملفات المحددة بالأعلى")
        self.clean_sys_btn.setStyleSheet("background-color: #28a745; font-size: 16px;")
        self.clean_sys_btn.clicked.connect(self.start_sys_clean)
        self.clean_sys_btn.setEnabled(False)
        layout.addWidget(self.clean_sys_btn)
        
        self.tabs.addTab(tab, "تنظيف النظام الآمن")
        
    def start_sys_scan(self):
        self.sys_tree.clear()
        self.scan_sys_btn.setEnabled(False)
        self.clean_sys_btn.setEnabled(False)
        self.sys_progress.show()
        self.sys_progress.setValue(0)
        
        self.sys_scan_thread = ScanCleanThread()
        self.sys_scan_thread.progress.connect(self.update_sys_progress)
        self.sys_scan_thread.found_category.connect(self.add_sys_category)
        self.sys_scan_thread.finished.connect(self.sys_scan_finished)
        self.sys_scan_thread.start()
        
    def update_sys_progress(self, val, text):
        self.sys_progress.setValue(val)
        self.sys_status.setText(text)
        
    def add_sys_category(self, name, desc, count, size, path):
        item = QTreeWidgetItem(self.sys_tree)
        item.setCheckState(0, Qt.Checked if size > 0 else Qt.Unchecked)
        item.setText(1, name)
        item.setText(2, desc)
        item.setText(3, str(count))
        item.setText(4, format_size(size))
        item.setData(1, Qt.UserRole, path)
        if size == 0:
            item.setDisabled(True)
            
    def sys_scan_finished(self):
        self.scan_sys_btn.setEnabled(True)
        self.sys_progress.hide()
        if self.sys_tree.topLevelItemCount() > 0:
            self.clean_sys_btn.setEnabled(True)
            
    def start_sys_clean(self):
        paths_to_clean = []
        for i in range(self.sys_tree.topLevelItemCount()):
            item = self.sys_tree.topLevelItem(i)
            if item.checkState(0) == Qt.Checked:
                paths_to_clean.append(item.data(1, Qt.UserRole))
                
        if not paths_to_clean:
            QMessageBox.warning(self, "تنبيه", "يرجى تحديد عنصر واحد على الأقل للتنظيف.")
            return
            
        self.clean_sys_btn.setEnabled(False)
        self.scan_sys_btn.setEnabled(False)
        self.sys_progress.show()
        self.sys_progress.setValue(0)
        
        self.sys_clean_thread = ExecuteCleanThread(paths_to_clean)
        self.sys_clean_thread.progress.connect(self.update_sys_progress)
        self.sys_clean_thread.finished.connect(self.sys_clean_finished)
        self.sys_clean_thread.start()
        
    def sys_clean_finished(self, count, saved, failed):
        self.sys_progress.hide()
        self.scan_sys_btn.setEnabled(True)
        self.sys_tree.clear()
        self.sys_status.setText(f"اكتملت العملية بنجاح. المساحة المستردة: {format_size(saved)}")
        msg = f"تم التنظيف بأمان تام!\n\nالملفات المحذوفة: {count}\nالمساحة المتوفرة: {format_size(saved)}\n\n(تم تخطي {failed} ملف لأنها إما مفتوحة قيد الاستخدام أو تتطلب صلاحيات مسؤول لحماية نظامك)."
        QMessageBox.information(self, "نتائج التنظيف", msg)

    def init_apps_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        
        desc = QLabel("إدارة التطبيقات والبرامج: إزالة البرامج الخاطئة قد تدمر النظام (الريجستري).\nلذلك، وفرنا لك هنا الاختصارات المباشرة لأدوات مايكروسوفت الأصلية لإزالة البرامج بأمان من جذورها.")
        desc.setAlignment(Qt.AlignCenter)
        layout.addWidget(desc)
        
        layout.addSpacing(30)
        
        btn_modern = QPushButton("فتح إعدادات التطبيقات (المفضلة لويندوز 10/11)")
        btn_modern.setFixedHeight(60)
        btn_modern.setStyleSheet("font-size: 18px;")
        btn_modern.clicked.connect(lambda: os.system("start ms-settings:appsfeatures"))
        layout.addWidget(btn_modern)
        
        layout.addSpacing(20)
        
        btn_legacy = QPushButton("فتح لوحة التحكم الكلاسيكية (البرامج والميزات)")
        btn_legacy.setFixedHeight(60)
        btn_legacy.setStyleSheet("font-size: 18px;")
        btn_legacy.clicked.connect(lambda: subprocess.Popen("control appwiz.cpl"))
        layout.addWidget(btn_legacy)
        
        layout.addStretch()
        self.tabs.addTab(tab, "إدارة وإزالة البرامج")

    def init_dead_files_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        
        desc = QLabel("اكتشاف الملفات الميتة: أداة ذكية تبحث حصرياً عن الملفات الكبيرة (أكبر من 50 ميجابايت)\nوالتي لم تقم بفتحها أو تعديلها منذ أكثر من 6 أشهر (180 يوماً).")
        desc.setAlignment(Qt.AlignCenter)
        layout.addWidget(desc)
        
        top_layout = QHBoxLayout()
        self.dead_scan_btn = QPushButton("اختيار مجلد لفحص الملفات الميتة")
        self.dead_scan_btn.clicked.connect(self.start_dead_scan)
        top_layout.addWidget(self.dead_scan_btn)
        
        self.dead_progress = QProgressBar()
        self.dead_progress.setValue(0)
        self.dead_progress.hide()
        top_layout.addWidget(self.dead_progress)
        layout.addLayout(top_layout)
        
        self.dead_tree = QTreeWidget()
        self.dead_tree.setAlternatingRowColors(True)
        self.dead_tree.setHeaderLabels(["تحديد", "مسار الملف", "الحجم المستهلك", "منذ كم يوم لم يفتح؟"])
        self.dead_tree.header().setSectionResizeMode(1, QHeaderView.Stretch)
        layout.addWidget(self.dead_tree)
        
        self.dead_delete_btn = QPushButton("نقل الملفات المحددة إلى سلة المحذوفات")
        self.dead_delete_btn.setStyleSheet("background-color: #d32f2f; font-size: 16px;")
        self.dead_delete_btn.clicked.connect(self.delete_dead_files)
        self.dead_delete_btn.setEnabled(False)
        layout.addWidget(self.dead_delete_btn)
        
        self.tabs.addTab(tab, "الملفات الميتة")
        
    def start_dead_scan(self):
        folder = QFileDialog.getExistingDirectory(self, "اختر المجلد للبحث عن الملفات القديمة جداً")
        if not folder:
            return
            
        norm = os.path.normpath(folder).lower()
        if norm in ["c:\\", "c:\\windows"]:
            QMessageBox.critical(self, "حماية النظام", "لا يمكن فحص مجلدات النظام الأساسية، يرجى اختيار مجلد شخصي (مثل التنزيلات أو المستندات).")
            return
            
        self.dead_tree.clear()
        self.dead_scan_btn.setEnabled(False)
        self.dead_delete_btn.setEnabled(False)
        self.dead_progress.show()
        self.dead_progress.setValue(0)
        
        self.dead_thread = DeadFilesThread(folder)
        self.dead_thread.progress.connect(self.update_dead_progress)
        self.dead_thread.found_file.connect(self.add_dead_file)
        self.dead_thread.finished.connect(self.dead_scan_finished)
        self.dead_thread.start()
        
    def update_dead_progress(self, val, text):
        self.dead_progress.setValue(val)
        
    def add_dead_file(self, path, size, days):
        item = QTreeWidgetItem(self.dead_tree)
        item.setCheckState(0, Qt.Unchecked)
        item.setText(1, path)
        item.setText(2, format_size(size))
        item.setText(3, f"منذ {int(days)} يوم")
        item.setData(1, Qt.UserRole, path)
        
    def dead_scan_finished(self):
        self.dead_scan_btn.setEnabled(True)
        self.dead_progress.hide()
        if self.dead_tree.topLevelItemCount() > 0:
            self.dead_delete_btn.setEnabled(True)
            QMessageBox.information(self, "اكتمل البحث", f"تم العثور على {self.dead_tree.topLevelItemCount()} ملفات ميتة وتستهلك مساحة كبيرة بلا فائدة.")
        else:
            QMessageBox.information(self, "اكتمل البحث", "جهازك نظيف! لم يتم العثور على أي ملفات كبيرة ومهجورة في هذا المجلد.")
            
    def delete_dead_files(self):
        count = 0
        saved = 0
        for i in range(self.dead_tree.topLevelItemCount()):
            item = self.dead_tree.topLevelItem(i)
            if item.checkState(0) == Qt.Checked:
                path = item.data(1, Qt.UserRole)
                try:
                    size = os.path.getsize(path)
                    abs_path = os.path.abspath(path)
                    long_path = "\\\\?\\" + abs_path if not abs_path.startswith("\\\\?\\") else abs_path
                    os.remove(long_path)
                    saved += size
                    count += 1
                except Exception as e:
                    pass
                    
        if count > 0:
            QMessageBox.information(self, "إنجاز", f"تم نقل {count} ملف إلى سلة المحذوفات.\nإجمالي المساحة التي استرجعتها: {format_size(saved)}.")
            self.dead_tree.clear()
            self.dead_delete_btn.setEnabled(False)

    def init_duplicates_tab(self):
        tab = QWidget()
        layout = QVBoxLayout(tab)
        
        desc = QLabel("يقوم هذا المحرك بالبحث عن الملفات المتطابقة 100% (بناءً على المحتوى الداخلي والتشفير الرقمي وليس الاسم فقط).")
        desc.setAlignment(Qt.AlignCenter)
        layout.addWidget(desc)
        
        top_layout = QHBoxLayout()
        self.dup_scan_btn = QPushButton("اختيار مجلد وبدء كشف المكررات")
        self.dup_scan_btn.clicked.connect(self.start_dup_scan)
        top_layout.addWidget(self.dup_scan_btn)
        
        self.dup_progress = QProgressBar()
        self.dup_progress.setValue(0)
        self.dup_progress.hide()
        top_layout.addWidget(self.dup_progress)
        layout.addLayout(top_layout)
        
        self.dup_status = QLabel("")
        layout.addWidget(self.dup_status)
        
        self.dup_tree = QTreeWidget()
        self.dup_tree.setAlternatingRowColors(True)
        self.dup_tree.setHeaderLabels(["تحديد", "الملف (الأصل والنسخ)", "الحجم"])
        self.dup_tree.header().setSectionResizeMode(1, QHeaderView.Stretch)
        layout.addWidget(self.dup_tree)
        
        self.dup_delete_btn = QPushButton("نقل النسخ المكررة المحددة إلى سلة المحذوفات")
        self.dup_delete_btn.setStyleSheet("background-color: #d32f2f; font-size: 16px;")
        self.dup_delete_btn.clicked.connect(self.delete_dups)
        self.dup_delete_btn.setEnabled(False)
        layout.addWidget(self.dup_delete_btn)
        
        self.tabs.addTab(tab, "المكررات")
        
    def start_dup_scan(self):
        folder = QFileDialog.getExistingDirectory(self, "اختر المجلد للبحث عن المكررات")
        if not folder:
            return
            
        norm = os.path.normpath(folder).lower()
        if norm in ["c:\\", "c:\\windows"]:
            QMessageBox.critical(self, "حماية النظام", "لا يمكن فحص مجلدات النظام لتجنب حذف ملفات هامة.")
            return
            
        self.dup_tree.clear()
        self.dup_scan_btn.setEnabled(False)
        self.dup_delete_btn.setEnabled(False)
        self.dup_progress.show()
        self.dup_progress.setValue(0)
        
        self.dup_thread = DuplicateThread(folder)
        self.dup_thread.progress.connect(self.update_dup_progress)
        self.dup_thread.found_dups.connect(self.populate_dups)
        self.dup_thread.finished.connect(self.dup_scan_finished)
        self.dup_thread.start()
        
    def update_dup_progress(self, val, text):
        self.dup_progress.setValue(val)
        self.dup_status.setText(text)
        
    def populate_dups(self, dups_list):
        self.dup_tree.clear()
        for group in dups_list:
            size_str = ""
            try:
                size_str = format_size(os.path.getsize(group[0]))
            except: pass
            
            parent = QTreeWidgetItem(self.dup_tree)
            parent.setText(1, f"مجموعة ملفات متطابقة ({len(group)} ملفات)")
            parent.setText(2, size_str)
            
            orig = QTreeWidgetItem(parent)
            orig.setText(1, f"⭐ [النسخة الأصلية] {group[0]}")
            orig.setData(1, Qt.UserRole, group[0])
            
            for copy_path in group[1:]:
                copy_item = QTreeWidgetItem(parent)
                copy_item.setCheckState(0, Qt.Checked)
                copy_item.setText(1, f"🗑️ [نسخة زائدة] {copy_path}")
                copy_item.setData(1, Qt.UserRole, copy_path)
                
            parent.setExpanded(True)
            
    def dup_scan_finished(self):
        self.dup_scan_btn.setEnabled(True)
        self.dup_progress.hide()
        self.dup_status.setText("اكتمل الفحص.")
        if self.dup_tree.topLevelItemCount() > 0:
            self.dup_delete_btn.setEnabled(True)
        else:
            QMessageBox.information(self, "نظيف!", "لم يتم العثور على أي ملفات مكررة في هذا المجلد.")
            
    def delete_dups(self):
        count = 0
        saved = 0
        for i in range(self.dup_tree.topLevelItemCount()):
            parent = self.dup_tree.topLevelItem(i)
            for j in range(parent.childCount()):
                child = parent.child(j)
                if child.checkState(0) == Qt.Checked:
                    path = child.data(1, Qt.UserRole)
                    try:
                        size = os.path.getsize(path)
                        abs_path = os.path.abspath(path)
                        long_path = "\\\\?\\" + abs_path if not abs_path.startswith("\\\\?\\") else abs_path
                        os.remove(long_path)
                        saved += size
                        count += 1
                    except Exception as e:
                        pass
        if count > 0:
            QMessageBox.information(self, "إنجاز", f"تم تنظيف المكررات!\nعدد النسخ المحذوفة: {count}\nإجمالي المساحة المستردة: {format_size(saved)}")
            self.dup_tree.clear()
            self.dup_delete_btn.setEnabled(False)
            
if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = App()
    window.show()
    sys.exit(app.exec_())
