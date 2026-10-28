import os
import re
import subprocess
import sys

def unpack_markdown(md_filename):
    if not os.path.exists(md_filename):
        print(f"❌ Файл {md_filename} не найден!")
        return False
        
    print(f"📖 Чтение и парсинг {md_filename}...")
    with open(md_filename, 'r', encoding='utf-8') as f:
        content = f.read()

    lines = content.split('\n')
    current_file = None
    current_code = []
    in_code_block = False
    extracted_files = {}

    for line in lines:
        # Регулярное выражение ищет **Файл:** `путь/к/файлу`
        file_match = re.search(r'\*\*Файл:\*\*\s*`([^`]+)`', line)
        if file_match and not in_code_block:
            current_file = file_match.group(1).strip()
            continue
            
        if line.strip().startswith('```'):
            if in_code_block:
                # Конец блока кода
                if current_file:
                    extracted_files[current_file] = '\n'.join(current_code)
                    current_file = None
                current_code = []
                in_code_block = False
            else:
                # Начало блока кода
                in_code_block = True
            continue
            
        if in_code_block:
            current_code.append(line)

    if not extracted_files:
        print("⚠️ Не удалось найти размеченные блоки кода.")
        return False

    print(f"📦 Распознано файлов: {len(extracted_files)}")
    
    # Создание директорий и запись файлов
    for filepath, code in extracted_files.items():
        full_path = os.path.join(os.getcwd(), filepath)
        directory = os.path.dirname(full_path)
        
        if directory and not os.path.exists(directory):
            os.makedirs(directory, exist_ok=True)
            
        with open(full_path, 'w', encoding='utf-8') as out:
            out.write(code.strip() + '\n')
        print(f"📄 Создан: {filepath}")

    return True

def run_command(command, description):
    print(f"\n⚙️ {description}...")
    try:
        subprocess.run(command, shell=True, check=True)
        print(f"✅ Успешно: {description}")
    except subprocess.CalledProcessError as e:
        print(f"❌ Ошибка при выполнении: {description}")
        sys.exit(e.returncode)

def main():
    print("=== Автоматический установщик Family Tree ===")
    
    target_md = "family_tree_complete_code.md"
    if len(sys.argv) > 1:
        target_md = sys.argv[1]
    elif not os.path.exists(target_md):
        # Поиск любого .md файла в директории
        md_candidates = [f for f in os.listdir('.') if f.endswith('.md')]
        if md_candidates:
            target_md = md_candidates[0]
            
    if not unpack_markdown(target_md):
        return

    # Запуск сборки
    run_command("flutter pub get", "Установка зависимостей (flutter pub get)")
    run_command("flutter pub run build_runner build --delete-conflicting-outputs", "Кодогенерация (Freezed & Riverpod)")
    
    print("\n🎉 Проект полностью развернут и сгенерирован!")
    print("💡 Укажите ключи Supabase в файле lib/main.dart и запустите приложение через flutter run.")

if __name__ == '__main__':
    main()