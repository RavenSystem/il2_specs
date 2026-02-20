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
IL2_VERSION="7.002"
PILOTS_NOTES_VERSION="11.3"
###

mkdir -p "$TARGET_DIR/images"
mkdir -p "$TARGET_DIR/pilots_notes"
mkdir -p "$TARGET_DIR/cockpits"
mkdir -p "$TARGET_DIR/manuals"

# Prepare Pilots Notes
mv -f Another\ Pilots\ Notes\ for\ CockPit\ Photos\ official\ numbers\ v*/data/graphics/Planes/ ./planes_notes &&
cd planes_notes &&
for i in $( ls ); do mv -f $i `echo $i | tr 'A-Z' 'a-z'`; done &&
cd ..

GENERATION_DATE="`date +%Y-%m-%d`"

printf "
# IL-2: Sturmovik Great Battles: Vehicle Specifications

Version: $IL2_VERSION - Date: $GENERATION_DATE [ [Sponsor this project](https://paypal.me/ravensystem) ] [ [GitHub](https://github.com/RavenSystem/il2_specs) ]

[ [Pilots Notes v$PILOTS_NOTES_VERSION WWII by lefuneste & WWI by Charlo](https://forum.il2-series.com/topic/42-another-pilots-notes-for-cockpit-photos/) ] [ [Game Manuals](#game-manuals) ] 

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
                IL2_MANUAL="文档"
                ;;
                "eng")
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                IL2_MANUAL="Document"
                ;;
                "fra")
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                IL2_MANUAL="Document"
                ;;
                "ger")
                IL2_DESCRIPTION="Beschreibung"
                IL2_MODIFICATIONS="Änderungen"
                IL2_MANUAL="Dokument"
                ;;
                "pol")
                IL2_DESCRIPTION="Opis"
                IL2_MODIFICATIONS="Modyfikacje"
                IL2_MANUAL="Dokument"
                ;;
                "rus")
                IL2_DESCRIPTION="Описание"
                IL2_MODIFICATIONS="Модификации"
                IL2_MANUAL="документ"
                ;;
                "spa")
                IL2_DESCRIPTION="Descripción"
                IL2_MODIFICATIONS="Modificaciones"
                IL2_MANUAL="Documento"
                ;;
            esac
            
            COCKPIT_IMAGE="$VEHICLE_NAME.$IL2_LOCALE.jpg"
            if [ ! -f "$TARGET_DIR/cockpits/$COCKPIT_IMAGE" ]; then
                COCKPIT_IMAGE="$VEHICLE_NAME.eng.jpg"
            fi

            cat "$VEHICLE_TYPE/$VEHICLE_NAME/info.locale=$IL2_LOCALE.txt" > "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            sed -i.bak -e 's/.*&name=/# /g' "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            TABLE_DETAILS="<table><tbody><tr><td style=\"text-align: center\"><img src=\"..\/images\/$NEW_VEHICLE_NAME.png\">"
            
            if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
                TABLE_DETAILS="$TABLE_DETAILS<\/td><td style=\"text-align: center\"><img src=\"..\/pilots_notes\/$NEW_VEHICLE_NAME.png\">"
            fi
            
            if [ -f "$TARGET_DIR/cockpits/$COCKPIT_IMAGE" ]; then
                TABLE_DETAILS="$TABLE_DETAILS<\/td><\/tr><tr><td style=\"text-align: center\""
                
                if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
                    TABLE_DETAILS="$TABLE_DETAILS colspan=\"2\""
                fi
                
                TABLE_DETAILS="$TABLE_DETAILS><img src=\"..\/cockpits\/$COCKPIT_IMAGE\">"
            fi
            
            TABLE_DETAILS="$TABLE_DETAILS<\/td><\/tr><\/tbody><\/table>\n"
            
            # Real Manuals
            for NUMBER in {01..99}; do
                IS_FIRST_MANUAL=1
                for IL2_MANUAL_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
                    if [ -f "$TARGET_DIR/real_manuals/$NEW_VEHICLE_NAME.$NUMBER.$IL2_MANUAL_LOCALE.pdf" ]; then
                        if [ $IS_FIRST_MANUAL -eq 1 ]; then
                            IS_FIRST_MANUAL=0
                            TABLE_DETAILS="$TABLE_DETAILS\n- $IL2_MANUAL $NUMBER "
                        fi
                        
                        TABLE_DETAILS="$TABLE_DETAILS[ [$IL2_MANUAL_LOCALE](..\/real_manuals\/$NEW_VEHICLE_NAME.$NUMBER.$IL2_MANUAL_LOCALE.pdf) ] "
                    fi
                done
            done
            
            TABLE_DETAILS="$TABLE_DETAILS\n\n## $IL2_DESCRIPTION"
            
            sed -i.bak -e "s/&description=/\n$TABLE_DETAILS\n\n/g" "$TARGET_DIR/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
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
        
        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            printf "[ [$IL2_LOCALE]($VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md) ] " >> "$TARGET_DIR/README.md"
        done
        
        printf "\n\n<table><tbody><tr><td style=\"text-align: center\">" >> "$TARGET_DIR/README.md"
        printf "<img src=\"images/$NEW_VEHICLE_NAME.png\">" >> "$TARGET_DIR/README.md"
        
        if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
            printf "</td><td style=\"text-align: center\">" >> "$TARGET_DIR/README.md"
            printf "<img src=\"pilots_notes/$NEW_VEHICLE_NAME.png\">" >> "$TARGET_DIR/README.md"
        fi
        
        printf "</td></tr></tbody></table>\n\n" >> "$TARGET_DIR/README.md"
    done

    rm -f "$TARGET_DIR/$VEHICLE_TYPE/\.\!"*
done

printf "
## Game Manuals

- Il-2 Great Battles: Operators [ [eng](manuals/IL2GB_Operators_Manual_v4702_Release.pdf) ] 
- Il-2 Great Battles: Purchase and Install [ [eng](manuals/IL2GB_Purchase_&_Install_Manual_v4702_Release.pdf) ] 
- Il-2 Great Battles: Mission Editor and Multiplayer Server [ [eng](manuals/IL-2_Sturmovik_Mission_Editor_and_Multiplayer_Server_Manual.pdf) ] [ [spa](manuals/Manual_del_Editor_de_Misiones_y_Servidor_Multijugador.pdf) ] 
- Il-2 Battle of Stalingrad: User Manual [ [eng](manuals/IL2_BOS_Manual_English_1011_rev1.pdf) ] [ [spa](manuals/IL2_BOS_Manual_Spanish_1011_rev1.pdf) ] 
- Rise of Flight: User Manual [ [eng](manuals/ROF_Manual_English_133c_rev1.pdf) ] [ [fra](manuals/ROF_Manual_French_133c_rev1.pdf) ] [ [ger](manuals/ROF_Manual_German_133c_rev1.pdf) ] [ [rus](manuals/ROF_Manual_Russian_133c_rev1.pdf) ] [ [spa](manuals/ROF_Manual_Spanish_133c_rev1.pdf) ] 


## Credits

- Planes and vehicles specifications texts are taken directly from in-game data of [Il-2 Sturmovik Great Battles](https://il2-series.com).
- Pilots Notes of WWII planes are by [lefuneste](https://forum.il2-series.com/profile/214-lefuneste/).
- Pilots Notes of WWI planes are by [Charlo](https://forum.il2-series.com/profile/215-charlo/).
- Cockpits images of WWII planes are from Il-2 Battle of Stalingrad: User Manual and [Luke \"LukeFF\" Wallace](https://forum.il2-series.com/profile/5-lukeff/).
- Cockpits images of WWI planes are from Rise of Flight: User Manual.
- Historical documents are from archive.org, scribd.com and internet forums.

" >> "$TARGET_DIR/README.md"
