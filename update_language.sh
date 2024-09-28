#!/bin/bash

# Ścieżka do folderu szablonów Pterodactyl Panel
TEMPLATE_DIR="/var/www/pterodactyl/resources/views/layouts"
LANGUAGE_SCRIPT_PATH="$TEMPLATE_DIR/language_switcher.blade.php"

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
cat <<EOL > "$LANGUAGE_SCRIPT_PATH"
<div class="language-switcher">
    <a href="#" onclick="changeLanguage('pl')">
        <img src="https://flagcdn.com/w20/pl.png" alt="Polski" width="20" height="15">
    </a>
    <a href="#" onclick="changeLanguage('en')">
        <img src="https://flagcdn.com/w20/gb.png" alt="English" width="20" height="15">
    </a>
</div>

<h1 id="page-title">Welcome to Pterodactyl Panel</h1>
<p id="page-description">Manage your game servers with ease.</p>

<script>
const translations = {
    pl: {
        title: "Witaj w Pterodactyl Panel",
        description: "Zarządzaj swoimi serwerami gier z łatwością."
    },
    en: {
        title: "Welcome to Pterodactyl Panel",
        description: "Manage your game servers with ease."
    }
};

function changeLanguage(lang) {
    localStorage.setItem('language', lang);
    updateContent(lang);
    location.reload();
}

function updateContent(lang) {
    document.getElementById("page-title").innerText = translations[lang].title;
    document.getElementById("page-description").innerText = translations[lang].description;
}

window.onload = function() {
    var lang = localStorage.getItem('language') || 'en'; // Domyślny język to angielski
    updateContent(lang);
};
</script>
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
