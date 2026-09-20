import sys
import os
import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin, urlparse

from PyQt5.QtWidgets import (QApplication, QMainWindow, QWidget, QVBoxLayout, 
                             QHBoxLayout, QPushButton, QLabel, QLineEdit, 
                             QProgressBar, QFileDialog, QMessageBox, QTextEdit)
from PyQt5.QtCore import Qt, QThread, pyqtSignal

class ImageScraperThread(QThread):
    progress = pyqtSignal(int, str)
    finished = pyqtSignal(int, str)
    log = pyqtSignal(str)
    
    def __init__(self, url, output_folder):
        super().__init__()
        self.url = url
        self.output_folder = output_folder
        
    def run(self):
        headers = {
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
        }
        
        self.progress.emit(10, "جاري الاتصال بالموقع وقراءة الكود المصدري...")
        self.log.emit(f"بدء فحص الرابط: {self.url}")
        
        try:
            response = requests.get(self.url, headers=headers, timeout=15)
            response.raise_for_status()
        except Exception as e:
            self.finished.emit(0, f"فشل الاتصال بالموقع: {str(e)}")
            return

        self.progress.emit(30, "جاري استخراج روابط الصور من الصفحة...")
        soup = BeautifulSoup(response.text, "html.parser")
        
        img_tags = soup.find_all("img")
        meta_tags = soup.find_all("meta", property="og:image")
        
        urls = []
        for img in img_tags:
            src = img.get("src") or img.get("data-src")
            if src and not src.startswith("data:image"):
                urls.append(urljoin(self.url, src))
                
        for meta in meta_tags:
            src = meta.get("content")
            if src:
                urls.append(urljoin(self.url, src))
                
        urls = list(set(urls)) # إزالة التكرار
        total = len(urls)
        
        if total == 0:
            self.finished.emit(0, "لم يتم العثور على أي صور في هذا الرابط.")
            return
            
        self.log.emit(f"تم العثور على {total} صورة. بدء التحميل...")
        
        if not os.path.exists(self.output_folder):
            os.makedirs(self.output_folder)
            
        count = 0
        for i, img_url in enumerate(urls):
            perc = 30 + int((i / total) * 70)
            self.progress.emit(perc, f"جاري تحميل الصورة {i+1} من {total}...")
            
            try:
                img_data = requests.get(img_url, headers=headers, timeout=10).content
                parsed = urlparse(img_url)
                filename = os.path.basename(parsed.path)
                
                if not filename:
                    filename = f"image_{count}.jpg"
                if not any(filename.lower().endswith(ext) for ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.ico']):
                    filename += ".jpg"
                    
                # منع تكرار الأسماء
                filepath = os.path.join(self.output_folder, filename)
                base, ext = os.path.splitext(filepath)
                file_idx = 1
                while os.path.exists(filepath):
                    filepath = f"{base}_{file_idx}{ext}"
                    file_idx += 1
                    
                with open(filepath, 'wb') as f:
                    f.write(img_data)
                    
                count += 1
                self.log.emit(f"✅ تم تحميل: {filename}")
            except Exception as e:
                self.log.emit(f"❌ فشل تحميل: {img_url}")
                
        self.progress.emit(100, "اكتملت العملية!")
        self.finished.emit(count, "نجاح")

class ImageExtractorApp(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("أداة سحب الصور من المواقع (Image Extractor)")
        self.resize(700, 500)
        self.setLayoutDirection(Qt.RightToLeft)
        
        self.setStyleSheet("""
            QMainWindow { background-color: #1e1e1e; }
            QWidget { color: #f0f0f0; font-family: 'Segoe UI', Tahoma; font-size: 14px; }
            QLineEdit { padding: 10px; border: 1px solid #444; border-radius: 5px; background: #2d2d30; color: white; }
            QPushButton { background-color: #007acc; color: white; border: none; padding: 10px; border-radius: 5px; font-weight: bold; }
            QPushButton:hover { background-color: #005f9e; }
            QPushButton:disabled { background-color: #444; color: #888; }
            QTextEdit { background-color: #252526; border: 1px solid #333; padding: 5px; }
            QProgressBar { border: 1px solid #444; border-radius: 5px; text-align: center; background-color: #2d2d30; height: 20px; }
            QProgressBar::chunk { background-color: #28a745; border-radius: 5px; }
        """)
        
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        layout = QVBoxLayout(main_widget)
        
        title = QLabel("أداة سحب الصور من أي رابط 🌐")
        title.setStyleSheet("font-size: 20px; font-weight: bold; color: #4fc3f7; padding: 10px;")
        title.setAlignment(Qt.AlignCenter)
        layout.addWidget(title)
        
        # Link Input
        layout.addWidget(QLabel("رابط الموقع (URL):"))
        self.url_input = QLineEdit()
        self.url_input.setPlaceholderText("https://poki.com/ar/g/shenzhen-mahjong")
        layout.addWidget(self.url_input)
        
        # Folder Select
        folder_layout = QHBoxLayout()
        self.folder_input = QLineEdit()
        self.folder_input.setPlaceholderText("اختر مجلد حفظ الصور...")
        self.folder_input.setReadOnly(True)
        self.folder_input.setText(os.path.join(os.path.expanduser("~"), "Desktop", "صور_مسحوبة"))
        folder_layout.addWidget(self.folder_input)
        
        btn_browse = QPushButton("تغيير المجلد")
        btn_browse.clicked.connect(self.browse_folder)
        folder_layout.addWidget(btn_browse)
        layout.addLayout(folder_layout)
        
        # Action Button
        self.btn_start = QPushButton("بدء سحب الصور الآن 🚀")
        self.btn_start.setStyleSheet("background-color: #d81b60; font-size: 16px; padding: 15px;")
        self.btn_start.clicked.connect(self.start_scraping)
        layout.addWidget(self.btn_start)
        
        # Progress
        self.progress_bar = QProgressBar()
        self.progress_bar.setValue(0)
        self.progress_bar.hide()
        layout.addWidget(self.progress_bar)
        
        self.status_lbl = QLabel("")
        layout.addWidget(self.status_lbl)
        
        # Logs
        layout.addWidget(QLabel("سجل العمليات:"))
        self.log_box = QTextEdit()
        self.log_box.setReadOnly(True)
        layout.addWidget(self.log_box)
        
    def browse_folder(self):
        folder = QFileDialog.getExistingDirectory(self, "اختر مجلد الحفظ")
        if folder:
            self.folder_input.setText(folder)
            
    def start_scraping(self):
        url = self.url_input.text().strip()
        folder = self.folder_input.text().strip()
        
        if not url.startswith("http"):
            QMessageBox.warning(self, "خطأ", "يرجى إدخال رابط صحيح يبدأ بـ http أو https")
            return
            
        self.btn_start.setEnabled(False)
        self.progress_bar.show()
        self.progress_bar.setValue(0)
        self.log_box.clear()
        
        self.thread = ImageScraperThread(url, folder)
        self.thread.progress.connect(self.update_progress)
        self.thread.log.connect(self.append_log)
        self.thread.finished.connect(self.scraping_finished)
        self.thread.start()
        
    def update_progress(self, val, text):
        self.progress_bar.setValue(val)
        self.status_lbl.setText(text)
        
    def append_log(self, text):
        self.log_box.append(text)
        
    def scraping_finished(self, count, status):
        self.btn_start.setEnabled(True)
        if count > 0:
            QMessageBox.information(self, "إنجاز", f"تم سحب {count} صورة بنجاح!\nتجدها في: {self.folder_input.text()}")
            os.startfile(self.folder_input.text())
        else:
            if status != "نجاح":
                QMessageBox.critical(self, "فشل", status)
            else:
                QMessageBox.information(self, "نتيجة", "لم يتم العثور على صور لتحميلها.")

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = ImageExtractorApp()
    window.show()
    sys.exit(app.exec_())
