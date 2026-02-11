#!/bin/sh
#
# IL2 Specifications Data Composer Script for macOS
# (c) 2023-2026 José A. Jiménez Campos @RavenSystem
#
# - Windows:
# Use "unGTP-IL2.exe" to extract files over a copy from "swf.gtp" file.
#
# - macOS:
# Unzip and copy "Another Pilots Notes for CockPit Photos official numbers v..." folder into "worldobjects" directory.
# Copy and run this script into "worldobjects" directory.

### Composer Configuration Data
TARGET_DIR="/Users/jose/Documents/Software/Juegos/IL2-Sturmovik BoX/il2_specs"
IL2_VERSION="7.001"
###

mkdir -p "$TARGET_DIR/images"
mkdir -p "$TARGET_DIR/pilots_notes"

# Prepare Pilots Notes
mv -f Another\ Pilots\ Notes\ for\ CockPit\ Photos\ official\ numbers\ v*/data/graphics/Planes/ ./planes_notes &&
cd planes_notes &&
for i in $( ls ); do mv -f $i `echo $i | tr 'A-Z' 'a-z'`; done &&
cd ..

GENERATION_DATE="`date +%Y-%m-%d`"

printf "
# IL-2: Sturmovik Great Battles: Vehicle Specifications

Version: $IL2_VERSION - Date: $GENERATION_DATE

[ [Sponsor this project](https://paypal.me/ravensystem) ] [ [GitHub](https://github.com/RavenSystem/il2_specs) ]

[ [Pilots notes by lefuneste](https://forum.il2-series.com/topic/42-another-pilots-notes-for-cockpit-photos/) ]

" > "$TARGET_DIR/README.md"

for VEHICLE_TYPE in "planes" "vehicles"; do
    mkdir -p "$TARGET_DIR/$VEHICLE_TYPE"
    
    VEHICLE_TYPE_U="$(tr '[:lower:]' '[:upper:]' <<< ${VEHICLE_TYPE:0:1})${VEHICLE_TYPE:1}"
    printf "### $VEHICLE_TYPE_U\n\n" >> "$TARGET_DIR/README.md"
    
    ls -1 "$VEHICLE_TYPE" | grep -v random | while read VEHICLE_NAME; do
        NEW_VEHICLE_NAME="`printf "$VEHICLE_NAME" | sed 's/^_\(.*\)/\1/'`"
        
        CLEAN_VEHICLE_NAME="`head -1 "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" | tr -d '#\r\n' | sed 's/^.//g' | sed 's/  //g'`"
        LINK_VEHICLE_NAME="`printf "$CLEAN_VEHICLE_NAME" |  tr -d '.½/()' | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]'`"
        
        printf "[ [$CLEAN_VEHICLE_NAME](#$LINK_VEHICLE_NAME) ] " >> "$TARGET_DIR/README.md"
    done
    
    printf "\n\n" >> "$TARGET_DIR/README.md"
    
    rm -f "$TARGET_DIR/$VEHICLE_TYPE/\.\!"*
done


for VEHICLE_TYPE in "planes" "vehicles"; do
    mkdir -p "$TARGET_DIR/$VEHICLE_TYPE"

    VEHICLE_TYPE_U="$(tr '[:lower:]' '[:upper:]' <<< ${VEHICLE_TYPE:0:1})${VEHICLE_TYPE:1}"
    printf "## $VEHICLE_TYPE_U\n\n" >> "$TARGET_DIR/README.md"

    ls -1 "$VEHICLE_TYPE" | grep -v random | while read VEHICLE_NAME; do
        NEW_VEHICLE_NAME="`printf "$VEHICLE_NAME" | sed 's/^_\(.*\)/\1/'`"
        
        # Vehicle image
        cp -f "$VEHICLE_TYPE/$VEHICLE_NAME/preview2.png" "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
        
        if [[ " albatrosd5 fokkerd7 fokkerd7f fokkerdr1 fw190d9 p47d28 pfalzd3a se5a sopcamel sopdolphin spad13 u2vs " == *" $NEW_VEHICLE_NAME "* ]]; then
            sips --resampleHeightWidth 426 1024 "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
            sips --padToHeightWidth 512 1024 "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
        fi
        
        # Pilots notes
        if [ -f "./planes_notes/$VEHICLE_NAME/Textures/custom_photo.dds" ]; then
            sips --setProperty format png "./planes_notes/$VEHICLE_NAME/Textures/custom_photo.dds" -o "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png"
            sips --resampleHeight 512 "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png"
            sips --cropOffset 1 1 --cropToHeightWidth 512 350 "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png"
        fi
        
        # Vehicle details multilanguage
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

            cat "$VEHICLE_TYPE/$VEHICLE_NAME/info.locale=$IL2_LOCALE.txt" > "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            sed -i.bak -e 's/.*&name=/# /g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
                sed -i.bak -e "s/&description=/\n| Image | Notes\n|:---|:---\n| !\[$NEW_VEHICLE_NAME\]\(..\/images\/$NEW_VEHICLE_NAME.png\) | !\[$NEW_VEHICLE_NAME\]\(..\/pilots_notes\/$NEW_VEHICLE_NAME.png\)\n\n## $IL2_DESCRIPTION\n\n/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            else
                sed -i.bak -e "s/&description=/\n!\[$NEW_VEHICLE_NAME\]\(..\/images\/$NEW_VEHICLE_NAME.png\)\n\n## $IL2_DESCRIPTION\n\n/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            fi
            
            sed -i.bak -e "s/'//g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            if [ -d "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" ]; then
                printf "\n\n## $IL2_MODIFICATIONS" >> "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                
                ls -1 "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" | while read MOD; do
                    cat "$VEHICLE_TYPE/$VEHICLE_NAME/modifications/$MOD/info.locale=$IL2_LOCALE.txt" >> "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                    
                    # Add a "\n" if there is none present at the end of each modification text
                    if [ `tail -c 1 "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md" | xxd -p | grep -c 0a` -eq 0 ]; then
                        printf "\r\n" >> "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                    fi
                done

                sed -i.bak -e 's/&name=/\n### /g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e 's/&description=/\n/g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e "s/'//g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            fi
            
            # Add 2 blank spaces to the end of each line to show lists in the right way in GitHub
            sed -i.bak -e 's/[^[:print:]]*$/  &/g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            sed -i.bak -e 's/^  $//g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            sed -i.bak -e 's/\%25/\%/g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            rm -f "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md.bak"
        done

        printf "##" >> "$TARGET_DIR/README.md"
        head -1 "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" >> "$TARGET_DIR/README.md"
        printf "\n" >> "$TARGET_DIR/README.md"

        if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
            printf "| " >> "$TARGET_DIR/README.md"
        fi
        
        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            printf "[ [$IL2_LOCALE]($VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md) ] " >> "$TARGET_DIR/README.md"
        done
        
        if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
            printf " | Notes \n" >> "$TARGET_DIR/README.md"
            printf "|:---|:---\n" >> "$TARGET_DIR/README.md"
            printf "| ![$NEW_VEHICLE_NAME](images/$NEW_VEHICLE_NAME.png) | ![$NEW_VEHICLE_NAME](pilots_notes/$NEW_VEHICLE_NAME.png)" >> "$TARGET_DIR/README.md"
        else
            printf "\n![$NEW_VEHICLE_NAME](images/$NEW_VEHICLE_NAME.png)" >> "$TARGET_DIR/README.md"
        fi
        
        printf " \n\n" >> "$TARGET_DIR/README.md"
    done

    rm -f "$TARGET_DIR/$VEHICLE_TYPE/\.\!"*
done
