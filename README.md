# Protoman

A tool used to handle custom protocols.

## Configuration

URL Sample:

```url
expm://AppName?param1=value1
```

### Windows

```reg
Windows Registry Editor Version 5.00

[HKEY_CLASSES_ROOT\expm]
@="URL:"
"URL Protocol"=""

[HKEY_CLASSES_ROOT\expm\shell]

; [HKEY_CLASSES_ROOT\expm\DefaultIcon]
; @="C:\\Path\\to\\Protoman.ico"

[HKEY_CLASSES_ROOT\expm\shell\open]

[HKEY_CLASSES_ROOT\expm\shell\open\command]
@="\"C:\\PATH\\to\\Protoman.exe\" %1"
```

### Linux

1. Gnome

    ```shell
    gconftool-2 -t string -s /desktop/gnome/url-handlers/expm/command 'protoman "%s"'
    gconftool-2 -s /desktop/gnome/url-handlers/expm/needs_terminal false -t bool
    gconftool-2 -s /desktop/gnome/url-handlers/expm/enabled true -t bool
    ```

2. KDE
   1. Create Desktop Entry `protoman.desktop`

        ```ini
        [Desktop Entry]
        Encoding=UTF-8
        Version=1.0
        Type=Application
        Terminal=false
        Exec=/usr/bin/protoman %u
        Name=APT‑URL
        Comment=APT‑URL handler
        Icon=
        Categories=Application;Network;
        MimeType=x-scheme-handler/expm;
        ```

   2. Register

       1. As ROOT

            ```shell
            <!-- Copy -->
            cp protoman.desktop /usr/share/applications/
            <!-- Update -->
            update-desktop-database
            <!-- register protocol -->
            xdg-mime default protoman.desktop x-scheme-handler/expm
            ```

       2. As Normal User

            ```shell
            <!-- Copy -->
            cp protoman.desktop ~/.local/share/applications/;
            <!-- Update -->
            update-desktop-database ~/.local/share/applications/;
            <!-- register protocol -->
            cd ~/.local/share/applications/;
            xdg-mime default protoman.desktop x-scheme-handler/expm
            ```

## Roadmap

- [x] Windows Supported
  - [ ] with Enhanced Open Operation
- [ ] Linux Supported
- [ ] MacOS Supported

## References

- [CustomProtocolHandler](https://github.com/Bowen-0x00/CustomProtocolHandler)
