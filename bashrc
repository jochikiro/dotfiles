# ~/.bashrc - przenośny (Linux Mint / Debian / Ubuntu / Fedora / Nobara)
# Zbudowany od zera, każda sekcja jest opisana, żeby wiedzieć co tu jest i po co.

# --- Globalny config (Fedora/Nobara) ---------------------------------------
# Fedora trzyma kolory, completion i resztę systemowych rzeczy w /etc/bashrc
# i /etc/profile.d. Na Debianie/Mincie ten plik nie istnieje, więc jest pomijany.
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# --- PATH ------------------------------------------------------------------
# Foldery na własne programy (pip --user, pipx, własne skrypty). Warunek pilnuje,
# żeby po ponownym "source ~/.bashrc" nie dublować wpisów w PATH.
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# Odkomentuj, jeśli nie lubisz, że systemctl sam wrzuca wyniki do pagera (less):
# export SYSTEMD_PAGER=

# --- Tylko tryb interaktywny -----------------------------------------------
# Jeśli to nie jest terminal, w którym pracujesz (np. skrypt), nic dalej nie rób.
case $- in
    *i*) ;;
      *) return;;
esac

# --- Historia komend -------------------------------------------------------
HISTCONTROL=ignoreboth        # pomiń komendy zaczynające się spacją i duplikaty z rzędu
shopt -s histappend           # dopisuj do pliku historii zamiast nadpisywać
HISTSIZE=5000                 # ile komend w pamięci sesji
HISTFILESIZE=10000            # ile linijek w ~/.bash_history

# --- Opcje shella ----------------------------------------------------------
shopt -s checkwinsize         # dopasuj się do rozmiaru okna po każdej komendzie
shopt -s globstar             # ** = rekurencyjnie po podfolderach
shopt -s cdspell              # popraw drobne literówki w "cd"
shopt -s extglob              # rozszerzone wzorce plików, np. !(*.txt)

# --- Dopełnianie Tab (readline) --------------------------------------------
# Lista podpowiedzi po pierwszym Tab, ignorowanie wielkości liter, kolory.
# Przez "bind" zamiast ~/.inputrc, żeby wszystko było w jednym pliku (dotfiles).
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'set colored-stats on'

# --- less / lesspipe -------------------------------------------------------
# less potrafi zajrzeć do archiwów i plików binarnych (na Fedorze pakiet to
# lesspipe.sh, więc ta linijka tam po prostu nic nie robi).
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# --- Prompt ----------------------------------------------------------------
# Wymuszamy realny test kolorów przez tput (ważne pod SSH na różne maszyny).
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

# Zwykły user: niebieski, napis na sztywno "jchi@nobara" (prawdziwy user/host bez zmian).
# Root: czerwono-pomarańczowy, zawsze pokazuje prawdziwe "root" (\u), żeby nic nie maskować.
if [ "$color_prompt" = yes ]; then
    if [ "$(id -u)" -eq 0 ]; then
        PS1="\[\e[38;2;255;0;0m\]\u\[\e[0m\]\[\e[38;2;255;60;0m\]@\[\e[0m\]\[\e[38;2;255;120;0m\]nobara\[\e[0m\] \\$ "
    else
        PS1="\[\e[38;2;0;135;255m\]jchi\[\e[0m\]\[\e[38;2;95;135;255m\]@\[\e[0m\]\[\e[38;2;135;135;255m\]nobara\[\e[0m\] \\$ "
    fi
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# Tytuł okna/karty terminala: user@host: ścieżka
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# --- Kolory ls i grep ------------------------------------------------------
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# --- Kolorowy man ----------------------------------------------------------
# GROFF_NO_SGR każe groffowi używać starego stylu pogrubień, żeby
# LESS_TERMCAP_md/us miało co podmienić (bez tego nagłówki nie łapią koloru).
export GROFF_NO_SGR=1
export LESS_TERMCAP_mb=$'\e[1;31m'     # migający tekst - czerwony
export LESS_TERMCAP_md=$'\e[1;31m'     # pogrubienie - czerwony
export LESS_TERMCAP_me=$'\e[0m'        # koniec pogrubienia
export LESS_TERMCAP_so=$'\e[1;33;44m'  # wyróżnienie (pasek na dole) - żółty na niebieskim
export LESS_TERMCAP_se=$'\e[0m'        # koniec wyróżnienia
export LESS_TERMCAP_us=$'\e[4;1;32m'   # podkreślenie - zielony
export LESS_TERMCAP_ue=$'\e[0m'        # koniec podkreślenia

# --- Aliasy ----------------------------------------------------------------
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias ..='echo "cd .."; cd ..'

# Literówki: jak się pomylisz, alias i tak zrobi co trzeba
alias gerp='grep'
alias chomd='chmod'
alias suod='sudo'

# Twój publiczny adres IP
alias externalip='curl -sS https://ysap.sh/ip'

# Otwórz plik/link domyślną aplikacją (jak "open" w macOS)
command -v xdg-open &>/dev/null && alias open='xdg-open'

# Na Debianie/Mincie pakiet "bat" nazywa się "batcat" (konflikt nazw).
# Na Fedorze to samo narzędzie to po prostu "bat", więc alias się nie utworzy.
command -v batcat &>/dev/null && alias bat='batcat'

# Powiadomienie systemowe po długiej komendzie: sleep 10; alert
if command -v notify-send &> /dev/null; then
    alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'
fi

# --- Funkcje ---------------------------------------------------------------
# Kolorowy diff: colordiff plik1 plik2
colordiff() {
    local red=$(tput setaf 1 2>/dev/null)
    local green=$(tput setaf 2 2>/dev/null)
    local cyan=$(tput setaf 6 2>/dev/null)
    local reset=$(tput sgr0 2>/dev/null)

    diff -u "$@" | awk "
    /^\-/ { printf(\"%s\", \"$red\"); }
    /^\+/ { printf(\"%s\", \"$green\"); }
    /^@/  { printf(\"%s\", \"$cyan\"); }
    { print \$0 \"$reset\"; }"

    return "${PIPESTATUS[0]}"
}

# Timestamp unixowy na czytelną datę: epoch 1700000000 (bez argumentu: teraz)
epoch() {
    local num=${1:--1}
    printf '%(%B %d, %Y %-I:%M:%S %p %Z)T\n' "$num"
}

# --- Dodatkowe pliki -------------------------------------------------------
# Osobny plik na własne aliasy (opcjonalny)
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Fedora ładuje tu fragmenty configu (~/.bashrc.d/*.sh); działa też na innych systemach
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        [ -f "$rc" ] && . "$rc"
    done
    unset rc
fi

# --- Programowalne dopełnianie Tab (git, apt, dnf, systemctl...) -----------
# Ładujemy tylko jeśli system jeszcze tego nie zrobił (Fedora robi to sama
# przez /etc/bashrc, więc bez tego warunku wczytałoby się dwa razy).
if ! declare -F _init_completion >/dev/null 2>&1 && ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi
