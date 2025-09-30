#!/bin/sh
#
# IL2 Specifications Data Composer
# (c) 2023 José A. Jiménez Campos @RavenSystem
#
# Use "unGTP-IL2.exe" to extract files over a copy from "swf.gtp" file.
# Copy and run this script into "worldobjects" directory.

### Composer Configuration Data
TARGET_DIR="/Users/jose/Documents/Software/Juegos/IL2-Sturmovik GB/il2_specs"
IL2_VERSION="6.003"
###

mkdir -p "$TARGET_DIR/images"

GENERATION_DATE="`date +%Y-%m-%d`"

printf "
# IL-2: Sturmovik Great Battles: Vehicle Specifications

Version: $IL2_VERSION

Date: $GENERATION_DATE

[Sponsor this project](https://paypal.me/ravensystem)

[GitHub](https://github.com/RavenSystem/il2_specs)

" > "$TARGET_DIR/README.md"

for VEHICLE_TYPE in "planes" "vehicles"; do
    mkdir -p "$TARGET_DIR/$VEHICLE_TYPE"

    VEHICLE_TYPE_U="$(tr '[:lower:]' '[:upper:]' <<< ${VEHICLE_TYPE:0:1})${VEHICLE_TYPE:1}"
    printf "## $VEHICLE_TYPE_U\r\n\r\n" >> "$TARGET_DIR/README.md"

    ls -1 "$VEHICLE_TYPE" | grep -v random | while read VEHICLE_NAME; do
        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            case "$IL2_LOCALE" in
                "chs")
                IL2_DESCRIPTION="描述"
                IL2_MODIFICATIONS="修改"
                ;;
                "eng")
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                ;;
                "fra")
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                ;;
                "ger")
                IL2_DESCRIPTION="Beschreibung"
                IL2_MODIFICATIONS="Änderungen"
                ;;
                "pol")
                IL2_DESCRIPTION="Opis"
                IL2_MODIFICATIONS="Modyfikacje"
                ;;
                "rus")
                IL2_DESCRIPTION="Описание"
                IL2_MODIFICATIONS="Модификации"
                ;;
                "spa")
                IL2_DESCRIPTION="Descripción"
                IL2_MODIFICATIONS="Modificaciones"
                ;;
            esac
            
            NEW_VEHICLE_NAME="`printf "$VEHICLE_NAME" | sed 's/^_\(.*\)/\1/'`"
            
            cp -f "$VEHICLE_TYPE/$VEHICLE_NAME/preview2.png" "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"

            cat "$VEHICLE_TYPE/$VEHICLE_NAME/info.locale=$IL2_LOCALE.txt" > "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            sed -i.bak -e "s/.*&name=/# /g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            sed -i.bak -e "s/&description=/\r\n!\[$NEW_VEHICLE_NAME\]\(..\/images\/$NEW_VEHICLE_NAME.png\)\r\n\r\n## $IL2_DESCRIPTION\r\n\r\n/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            sed -i.bak -e "s/'//g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            if [ -d "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" ]; then
                printf "\r\n\r\n## $IL2_MODIFICATIONS\r\n" >> "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                
                ls -1 "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" | while read MOD; do
                    cat "$VEHICLE_TYPE/$VEHICLE_NAME/modifications/$MOD/info.locale=$IL2_LOCALE.txt" >> "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                done

                sed -i.bak -e "s/&name=/\r\n\n### /g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e "s/&description=/\r\n/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e "s/'//g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            fi

            sed -i.bak -e "s/[^[:print:]]*$/  &/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            sed -i.bak -e "s/\%25/\%/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            rm -f "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md.bak"
        done

        printf "##" >> "$TARGET_DIR/README.md"
        head -1 "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" >> "$TARGET_DIR/README.md"
        printf "\r\n" >> "$TARGET_DIR/README.md"

        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            printf "[ [$IL2_LOCALE]($VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md) ] " >> "$TARGET_DIR/README.md"
        done

        printf "\r\n![$NEW_VEHICLE_NAME](images/$NEW_VEHICLE_NAME.png)\r\n\r\n" >> "$TARGET_DIR/README.md"
    done

    rm -f "$TARGET_DIR/$VEHICLE_TYPE/\.\!"*
done
