#!/bin/bash

# Ścieżka do folderu szablonów Pterodactyl Panel
TEMPLATE_DIR="/var/www/pterodactyl/resources/views/layouts"
LANGUAGE_SCRIPT_PATH="$TEMPLATE_DIR/admin.blade.php"

# Sprawdź, czy folder szablonów istnieje
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Folder szablonów nie istnieje: $TEMPLATE_DIR"
    exit 1
fi

# Sprawdź, czy plik istnieje
if [ ! -f "$LANGUAGE_SCRIPT_PATH" ]; then
    echo "Plik szablonu nie istnieje: $LANGUAGE_SCRIPT_PATH"
    exit 1
fi

# Backup oryginalnego pliku
cp "$LANGUAGE_SCRIPT_PATH" "$LANGUAGE_SCRIPT_PATH.bak"
if [ $? -ne 0 ]; then
    echo "Błąd podczas tworzenia kopii zapasowej pliku."
    exit 1
fi

# Dodaj flagi do pliku szablonu
cat <<EOL >> "$LANGUAGE_SCRIPT_PATH"
<div class="language-switcher">
    <a href="#" onclick="changeLanguage('pl')">
        <img src="https://flagcdn.com/w20/pl.png" alt="Polski" width="20" height="15">
    </a>
    <a href="#" onclick="changeLanguage('en')">
        <img src="https://flagcdn.com/w20/gb.png" alt="English" width="20" height="15">
    </a>
</div>

<script>
function changeLanguage(lang) {
    const googleTranslateScript = document.createElement('script');
    googleTranslateScript.src = 'https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit';
    document.body.appendChild(googleTranslateScript);

    window.googleTranslateElementInit = function() {
        new google.translate.TranslateElement({
            pageLanguage: 'en', // język oryginalny strony
            includedLanguages: 'en,pl', // dostępne języki
            layout: google.translate.TranslateElement.InlineLayout.SIMPLE
        }, 'google_translate_element');

        const element = document.getElementById('google_translate_element');
        const select = element.querySelector('select');
        select.value = lang; // Ustaw wybrany język
        select.dispatchEvent(new Event('change'));
    };
}

window.onload = function() {
    const lang = localStorage.getItem('language') || 'en'; // Domyślny język to angielski
    changeLanguage(lang);
};
</script>
<div id="google_translate_element"></div>
EOL

# Sprawdź, czy zapisanie pliku powiodło się
if [ $? -ne 0 ]; then
    echo "Błąd podczas zapisywania pliku szablonu."
    exit 1
fi

# Restartuj serwer, aby zastosować zmiany
systemctl restart pterodactyl
if [ $? -ne 0 ]; then
    echo "Błąd podczas restartowania Pterodactyl Panel."
    exit 1
fi

echo "Zaktualizowano język w Pterodactyl Panel. Zrestartowano panel."
