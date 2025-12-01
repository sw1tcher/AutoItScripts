# AutoIt Scripts
# Default Printer Selector (AutoIt)
https://github.com/sw1tcher/AutoItScripts/edit/main/README.md#%D0%B2%D1%8B%D0%B1%D0%BE%D1%80-%D0%BF%D1%80%D0%B8%D0%BD%D1%82%D0%B5%D1%80%D0%B0-%D0%BF%D0%BE-%D1%83%D0%BC%D0%BE%D0%BB%D1%87%D0%B0%D0%BD%D0%B8%D1%8E-autoit

A lightweight Windows utility written in AutoIt that allows users to view all installed printers and change the default printer with a single click.

This tool is ideal for environments where users frequently switch between multiple printers, workstations with limited permissions, or situations where quick printer management is needed without opening Windows system dialogs.

---

## ✨ Features

- ✔ Displays the current default printer  
- ✔ Shows a list of all installed printers  
- ✔ Changes the default printer instantly via WMI  
- ✔ Works on Windows 7 / 8 / 10 / 11  
- ✔ No installation required — portable EXE can be created  
- ✔ Clean and minimalistic GUI  
- ✔ Compatible with older AutoIt builds

---

## 📌 How It Works

The script uses Windows WMI (`Win32_Printer`) to:

- Query the list of available printers  
- Fetch the current default printer  
- Set another printer as the new system default  

No admin rights are required unless system policies block printer management.

## 🚀 Running the Script

1. Install **AutoIt** (or use a portable AutoIt3 interpreter)  
2. Run `select_printer.au3`  
3. (Optional) Compile to EXE via **Aut2Exe**

---

## 🛠️ Requirements

- Windows 7 or newer  
- WMI enabled  
- AutoIt 3.3+  

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

## 🤝 Contributions

Pull requests and improvements are welcome!

---
# Выбор принтера по умолчанию (AutoIt)

Лёгкая утилита для Windows, написанная на AutoIt, позволяющая просматривать список установленных принтеров и менять принтер по умолчанию в один клик.

Подходит для офисов, рабочих мест с несколькими принтерами, терминалов с ограниченными правами или любых ситуаций, когда нужно быстро переключаться между принтерами без открытия системных диалогов Windows.

---

## ✨ Возможности

- ✔ Показывает текущий принтер по умолчанию  
- ✔ Отображает список всех установленных принтеров  
- ✔ Изменяет принтер по умолчанию через WMI  
- ✔ Работает на Windows 7 / 8 / 10 / 11  
- ✔ Не требует установки — можно собрать portable EXE  
- ✔ Минималистичный и понятный интерфейс  
- ✔ Совместимо со старыми версиями AutoIt  

---

## 📌 Как это работает

Скрипт использует WMI (`Win32_Printer`) для:

- получения списка принтеров  
- определения текущего принтера по умолчанию  
- установки другого принтера как нового системного default  

Админправа не требуются, если политики системы не запрещают управление принтерами.

---

## 🖼️ Скриншот

*(чуть позже)*

---

## 🚀 Запуск

1. Установите **AutoIt** (или используйте portable-версию интерпретатора)  
2. Запустите файл `select_printer.au3`  
3. (Опционально) Соберите EXE через **Aut2Exe**

---

## 🛠️ Требования

- Windows 7 или новее  
- Включённый WMI  
- AutoIt 3.3+  

---

## 📄 Лицензия

MIT License — свободно используйте, изменяйте и распространяйте.

---

## 🤝 Участие

PR-ы и улучшения приветствуются!

---


