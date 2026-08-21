$content = Get-Content -Path "lib/features/minigames/presentation/find_differences/find_differences_game.dart" -Raw
$content = $content -replace "label: '\\: \\/5'", "label: '$($copy.findDifferencesFound): $($_found.length)/5'"
$content = $content -replace "label: '\\: \\'", "label: '$($copy.findDifferencesMistakes): $($_mistakes)'"
Set-Content -Path "lib/features/minigames/presentation/find_differences/find_differences_game.dart" -Value $content
