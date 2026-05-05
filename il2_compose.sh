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
#
# RAVENSYSTEM_COCKPIT_NOTES_DIR is the full local path of the RavenSystem's Cockpit Photos GitHub repo clone
#
# (Run this script twice if there are new planes or missing images)

### Script Configuration Settings
IL2_VERSION="7.006"
PILOTS_NOTES_VERSION="11.3"

GITHUB_USER_REPO="RavenSystem/il2_specs"
RAVENSYSTEM_COCKPIT_GITHUB_USER_REPO="RavenSystem/il2_cockpit_photos"

TARGET_DIR="/Users/jose/Documents/Software/Juegos/IL2-Sturmovik BoX/il2_specs"
RAVENSYSTEM_COCKPIT_NOTES_DIR="/Users/jose/Documents/Software/Juegos/IL2-Sturmovik BoX/il2_cockpit_photos"
###

echo "STARTED"

GITHUB_RAW_CONTENT="https://raw.githubusercontent.com/$GITHUB_USER_REPO/refs/heads/main"
RAVENSYSTEM_COCKPIT_NOTES_BASENAME=$(basename "$RAVENSYSTEM_COCKPIT_NOTES_DIR")

# Create directories
echo "* Create directories"
mkdir -p "$TARGET_DIR/docs"
mkdir -p "$TARGET_DIR/images"
mkdir -p "$TARGET_DIR/images_other"
mkdir -p "$TARGET_DIR/pilots_notes"
mkdir -p "$TARGET_DIR/cockpits"
mkdir -p "$TARGET_DIR/manuals"
mkdir -p "$TARGET_DIR/real_manuals"
mkdir -p "$TARGET_DIR/personal_notes"
mkdir -p "$TARGET_DIR/tools"

# Prepare RavenSystem Cockpit Photos
echo "* Prepare RavenSystem Cockpit Photos"
if [ -d "$RAVENSYSTEM_COCKPIT_NOTES_DIR" ]; then
    rm -rf "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME"
    
    cp -rf "$RAVENSYSTEM_COCKPIT_NOTES_DIR" .
    
    if [ -d "$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/" ]; then
        cd "$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/"
        for i in $( ls ); do mv -f $i `echo $i | tr 'A-Z' 'a-z'`; done
        cd ../../../../
    fi
fi

# Prepare Another Pilots Notes
echo "* Prepare Another Pilots Notes"
cp -rf -f Another\ Pilots\ Notes\ for\ CockPit\ Photos\ official\ numbers\ v*/data/graphics/Planes/ ./planes_notes
if [ -d "./planes_notes" ]; then
    cd ./planes_notes
    for i in $( ls ); do mv -f $i `echo $i | tr 'A-Z' 'a-z'`; done
    cd ..
fi

GENERATION_DATE=$(date +%Y-%m-%d)

# Header
echo "* Header"
printf "
Date: $GENERATION_DATE - Game version: $IL2_VERSION [ [Sponsor this project](https://paypal.me/ravensystem) ] [ [GitHub](https://github.com/$GITHUB_USER_REPO) ]

[ [Game Manuals](#game-manuals) ] [ [Tools](#tools) ]

[ [Pilots Notes v$PILOTS_NOTES_VERSION WWII by lefuneste & WWI by Charlo](https://forum.il2-series.com/topic/42-another-pilots-notes-for-cockpit-photos/) ] 

" > "$TARGET_DIR/docs/README.md"


# Quick jump to
echo "* Quick jump to"
printf "**Jump to** " >> "$TARGET_DIR/docs/README.md"

printf "<select onchange=\"window.location.href=this.value\">\n" >> "$TARGET_DIR/docs/README.md"

for VEHICLE_TYPE in "planes" "vehicles"; do
    mkdir -p "$TARGET_DIR/docs/$VEHICLE_TYPE"
    
    VEHICLE_TYPE_U="$(tr '[:lower:]' '[:upper:]' <<< ${VEHICLE_TYPE:0:1})${VEHICLE_TYPE:1}"
    
    printf "<option value=\"\">--- $VEHICLE_TYPE_U</option>\n" >> "$TARGET_DIR/docs/README.md"
    
    ls -1 "$VEHICLE_TYPE" | grep -v random | while read VEHICLE_NAME; do
        NEW_VEHICLE_NAME="`printf "$VEHICLE_NAME" | sed 's/^_\(.*\)/\1/'`"
        
        CLEAN_VEHICLE_NAME="`head -1 "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" | tr -d '#\r\n' | sed 's/^.//g' | sed 's/  //g'`"
        LINK_VEHICLE_NAME="`printf "$CLEAN_VEHICLE_NAME" |  tr -d '.½/()' | sed 's/ /-/g' | tr '[:upper:]' '[:lower:]'`"
        
        printf "<option value=\"#$LINK_VEHICLE_NAME\">$CLEAN_VEHICLE_NAME</option>\n" >> "$TARGET_DIR/docs/README.md"
    done
    
    rm -f "$TARGET_DIR/docs/$VEHICLE_TYPE/\.\!"*
done

printf "</select>\n\n" >> "$TARGET_DIR/docs/README.md"

# Main loop, for planes and vehicles (tanks)
for VEHICLE_TYPE in "planes" "vehicles"; do
    echo "* $VEHICLE_TYPE Main loop"
    VEHICLE_TYPE_U="$(tr '[:lower:]' '[:upper:]' <<< ${VEHICLE_TYPE:0:1})${VEHICLE_TYPE:1}"
    printf "## $VEHICLE_TYPE_U\n\n" >> "$TARGET_DIR/docs/README.md"

    # Vehicle loop
    ls -1 "$VEHICLE_TYPE" | grep -v random | while read VEHICLE_NAME; do
        NEW_VEHICLE_NAME="`printf "$VEHICLE_NAME" | sed 's/^_\(.*\)/\1/'`"
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Vehicle loop"
        
        # Vehicle image
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Vehicle image"
        if [ ! -f "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png" ]; then
            cp -f "$VEHICLE_TYPE/$VEHICLE_NAME/preview2.png" "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
            
            if [[ " albatrosd5 fokkerd7 fokkerd7f fokkerdr1 fw190d9 p47d28 pfalzd3a se5a sopcamel sopdolphin spad13 u2vs " == *" $NEW_VEHICLE_NAME "* ]]; then
                sips --resampleHeightWidth 426 1024 "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
                sips --padToHeightWidth 512 1024 "$TARGET_DIR/images/$NEW_VEHICLE_NAME.png"
            fi
        fi
        
        # Another Pilots notes
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Another Pilots notes"
        if [ -f "./planes_notes/$VEHICLE_NAME/Textures/custom_photo.dds" ]; then
            sips --setProperty format png "./planes_notes/$VEHICLE_NAME/Textures/custom_photo.dds" -o "./planes_notes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            sips --resampleHeight 512 "./planes_notes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            sips --cropOffset 1 1 --cropToHeightWidth 512 350 "./planes_notes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            mv -f "./planes_notes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png" "$TARGET_DIR/pilots_notes/"
        fi
        
        # RavenSystem Cockpit Photos
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME RavenSystem Cockpit Photos"
        if [ -f "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/custom_photo.dds" ]; then
            sips --setProperty format png "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/custom_photo.dds" -o "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            sips --resampleHeight 512 "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            sips --cropOffset 1 1 --cropToHeightWidth 512 360 "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png"
            mv -f "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME/data/graphics/Planes/$VEHICLE_NAME/Textures/$NEW_VEHICLE_NAME.png" "$TARGET_DIR/personal_notes/"
        fi
        
        # Vehicle details loop for each language
        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Vehicle details loop"
            
            case "$IL2_LOCALE" in
                "chs")
                IL2_PERSONAL_NOTES="个人笔记"
                IL2_DESCRIPTION="描述"
                IL2_MODIFICATIONS="修改"
                ;;
                "eng")
                IL2_PERSONAL_NOTES="Personal Notes"
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                ;;
                "fra")
                IL2_PERSONAL_NOTES="Notes personnelles"
                IL2_DESCRIPTION="Description"
                IL2_MODIFICATIONS="Modifications"
                ;;
                "ger")
                IL2_PERSONAL_NOTES="Persönliche Notizen"
                IL2_DESCRIPTION="Beschreibung"
                IL2_MODIFICATIONS="Änderungen"
                ;;
                "pol")
                IL2_PERSONAL_NOTES="Notatki osobiste"
                IL2_DESCRIPTION="Opis"
                IL2_MODIFICATIONS="Modyfikacje"
                ;;
                "rus")
                IL2_PERSONAL_NOTES="Личные заметки"
                IL2_DESCRIPTION="Описание"
                IL2_MODIFICATIONS="Модификации"
                ;;
                "spa")
                IL2_PERSONAL_NOTES="Notas Personales"
                IL2_DESCRIPTION="Descripción"
                IL2_MODIFICATIONS="Modificaciones"
                ;;
            esac

            cat "$VEHICLE_TYPE/$VEHICLE_NAME/info.locale=$IL2_LOCALE.txt" > "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            sed -i.bak -e 's/.*&name=/# /g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            # Main Image
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Main Image"
            TABLE_DETAILS="<table><tbody><tr><td style=\"text-align: center\"><a href=\"$GITHUB_RAW_CONTENT/images/$NEW_VEHICLE_NAME.png\"><img src=\"$GITHUB_RAW_CONTENT/images/$NEW_VEHICLE_NAME.png\"></a>"
            
            # Generic Pilot Notes
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Generic Pilot Notes"
            if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
                TABLE_DETAILS="$TABLE_DETAILS</td><td width=\"25%\" style=\"text-align: center\"><a href=\"$GITHUB_RAW_CONTENT/pilots_notes/$NEW_VEHICLE_NAME.png\"><img src=\"$GITHUB_RAW_CONTENT/pilots_notes/$NEW_VEHICLE_NAME.png\"></a>"
            fi
            
            # Cockpit image
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Cockpit image"
            COCKPIT_IMAGE="$VEHICLE_NAME.$IL2_LOCALE.jpg"
            if [ ! -f "$TARGET_DIR/cockpits/$COCKPIT_IMAGE" ]; then
                COCKPIT_IMAGE="$VEHICLE_NAME.eng.jpg"
            fi
            
            if [ -f "$TARGET_DIR/cockpits/$COCKPIT_IMAGE" ]; then
                TABLE_DETAILS="$TABLE_DETAILS</td></tr><tr><td style=\"text-align: center\""
                
                if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
                    TABLE_DETAILS="$TABLE_DETAILS colspan=\"2\""
                fi
                
                TABLE_DETAILS="$TABLE_DETAILS><a href=\"$GITHUB_RAW_CONTENT/cockpits/$COCKPIT_IMAGE\"><img src=\"$GITHUB_RAW_CONTENT/cockpits/$COCKPIT_IMAGE\"></a>"
            fi
            
            TABLE_DETAILS="$TABLE_DETAILS</td></tr></tbody></table>\n"
            
            # Real Manuals
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Real Manuals"
            LAST_DOCUMENT_NAME="null..."
            for i in "$TARGET_DIR/real_manuals/$NEW_VEHICLE_NAME."*; do
                DOCUMENT_BASENAME=$(basename "$i")
                DOCUMENT_NAME=$(echo $DOCUMENT_BASENAME | cut -d . -f 2)
                DOCUMENT_NAME_WITH_SPACES=$(echo $DOCUMENT_NAME | sed 's/_/ /g')
                
                if [ "$LAST_DOCUMENT_NAME" = "$DOCUMENT_NAME" ]; then
                    continue
                fi
                
                LAST_DOCUMENT_NAME="$DOCUMENT_NAME"
                
                IS_FIRST_MANUAL=1
                for IL2_MANUAL_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
                    if [ -f "$TARGET_DIR/real_manuals/$NEW_VEHICLE_NAME.$DOCUMENT_NAME.$IL2_MANUAL_LOCALE.pdf" ]; then
                        if [ $IS_FIRST_MANUAL -eq 1 ]; then
                            IS_FIRST_MANUAL=0
                            TABLE_DETAILS="$TABLE_DETAILS\n- $DOCUMENT_NAME_WITH_SPACES "
                        fi
                        
                        TABLE_DETAILS="$TABLE_DETAILS[ [$IL2_MANUAL_LOCALE]($GITHUB_RAW_CONTENT/real_manuals/$NEW_VEHICLE_NAME.$DOCUMENT_NAME.$IL2_MANUAL_LOCALE.pdf) ] "
                    fi
                done
            done
            
            # Personal Notes
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Personal Notes"
            RAVENSYSTEM_NOTES_FILENAME="$NEW_VEHICLE_NAME.eng.html"
            if [ -f "$TARGET_DIR/personal_notes/$NEW_VEHICLE_NAME.$IL2_LOCALE.html" ]; then
                RAVENSYSTEM_NOTES_FILENAME="$NEW_VEHICLE_NAME.$IL2_LOCALE.html"
            fi
            
            if [ -f "$TARGET_DIR/personal_notes/$RAVENSYSTEM_NOTES_FILENAME" ]; then
                RAVENSYSTEM_NOTES_CONTENT=$(cat "$TARGET_DIR/personal_notes/$RAVENSYSTEM_NOTES_FILENAME")
                
                TABLE_DETAILS="$TABLE_DETAILS\n\n## $IL2_PERSONAL_NOTES\n\n"
                
                TABLE_DETAILS="$TABLE_DETAILS<table><tbody><tr><td valign=\"top\" style=\"text-align: left\">$RAVENSYSTEM_NOTES_CONTENT"
                
                if [ -f "$TARGET_DIR/personal_notes/$NEW_VEHICLE_NAME.png" ]; then
                    TABLE_DETAILS="$TABLE_DETAILS</td>\n<td width=\"25%\" valign=\"top\" style=\"text-align: center\"><a href=\"$GITHUB_RAW_CONTENT/personal_notes/$NEW_VEHICLE_NAME.png\"><img src=\"$GITHUB_RAW_CONTENT/personal_notes/$NEW_VEHICLE_NAME.png\"></a><br>[ <a href=\"https://github.com/$RAVENSYSTEM_COCKPIT_GITHUB_USER_REPO\">Cockpit Photos</a> ]"
                fi
                
                TABLE_DETAILS="$TABLE_DETAILS</td></tr></tbody></table>"
            fi
            
            # Description
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Description"
            TABLE_DETAILS="$TABLE_DETAILS\n\n## $IL2_DESCRIPTION"
        
            TABLE_DETAILS_ESCAPE=$(echo "$TABLE_DETAILS" | sed -e 's/\//\\\//g' | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/\\n/g')
            
            sed -i.bak -e "s/&description=/\n$TABLE_DETAILS_ESCAPE\n\n/g" "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            sed -i.bak -e "s/'//g" "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"

            # Modifications
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE Modifications"
            if [ -d "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" ]; then
                printf "\n\n## $IL2_MODIFICATIONS" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                
                ls -1 "$VEHICLE_TYPE/$VEHICLE_NAME/modifications" | while read MOD; do
                    cat "$VEHICLE_TYPE/$VEHICLE_NAME/modifications/$MOD/info.locale=$IL2_LOCALE.txt" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                    
                    # Add a "\n" if there is none present at the end of each modification text
                    if [ `tail -c 1 "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md" | xxd -p | grep -c 0a` -eq 0 ]; then
                        printf "\r\n" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                    fi
                done

                sed -i.bak -e 's/&name=/\n### /g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e 's/&description=/\n/g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                sed -i.bak -e "s/'//g" "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            fi
            
            # Add 2 blank spaces to the end of each line to show lists in the right way in GitHub
            sed -i.bak -e 's/[^[:print:]]*$/  &/g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            sed -i.bak -e 's/^  $//g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            sed -i.bak -e 's/\%25/\%/g' "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            
            # Add more images at bottom
            echo "*** $VEHICLE_TYPE $NEW_VEHICLE_NAME $IL2_LOCALE More images"
            IS_MORE_IMAGES=0
            for LOCAL_IMG_TYPE in "Isometric" "Left" "LeftUC" "Front" "Top" "Bottom" "Back"; do
                if [ -f "$TARGET_DIR/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg" ]; then
                    IS_MORE_IMAGES=1
                    break
                fi
            done
            
            if [ $IS_MORE_IMAGES -eq 1 ]; then
                printf "\n<table><tbody>" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                for LOCAL_IMG_TYPE in "Isometric" "Left" "LeftUC" "Front" "Top" "Bottom" "Back"; do
                    if [ -f "$TARGET_DIR/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg" ]; then
                        printf "<tr><td style=\"text-align: center\"><a href=\"$GITHUB_RAW_CONTENT/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg\"><img src=\"$GITHUB_RAW_CONTENT/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg\"></a></td></tr>\n" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
                    fi
                done
                printf "</tbody></table>\n" >> "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md"
            fi
            
            # Cleaning
            rm -f "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md.bak"
        done
        
        printf "##" >> "$TARGET_DIR/docs/README.md"
        head -1 "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" >> "$TARGET_DIR/docs/README.md"
        printf "\n" >> "$TARGET_DIR/docs/README.md"
        
        # Download more images
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Download more images"
        DOWNLOAD_VEHICLE_NAME=$(head -1 "$TARGET_DIR/docs/$VEHICLE_TYPE/$NEW_VEHICLE_NAME.eng.md" | sed -e 's/-/_/g' | sed -e 's/ /_/g' | sed -e 's/\.//g' | sed -e 's/\///g' | sed -e 's/(//g' | sed -e 's/)//g' | sed -e 's/^#_//g' | sed -e 's/__\r//g' | tr 'A-Z' 'a-z' | sed -e 's/fw_190_a_/fw_190_/g' )
        for IMG_TYPE in "Isometric" "Left" "Left%20UC" "Front" "Top" "Bottom" "Back"; do
            LOCAL_IMG_TYPE=$IMG_TYPE
            if [ "$IMG_TYPE" = "Left%20UC" ]; then
                LOCAL_IMG_TYPE="LeftUC"
            fi
            
            if [ "$DOWNLOAD_VEHICLE_NAME" = "fw_190_d_9" ]; then
                if [ "$IMG_TYPE" = "Isometric" ]; then
                    IMG_TYPE="Isometric%20Bubble%20Canopy"
                fi
            elif [ "$DOWNLOAD_VEHICLE_NAME" = "iar_80_a" ]; then
                DOWNLOAD_VEHICLE_NAME="ir_80_"
            elif [ "$DOWNLOAD_VEHICLE_NAME" = "iar_80_b" ]; then
                DOWNLOAD_VEHICLE_NAME="ir_80_b"
            elif [ "$DOWNLOAD_VEHICLE_NAME" = "la_5fn_ser_2" ]; then
                DOWNLOAD_VEHICLE_NAME="la_5fn_series_2"
            fi
            
            if [ ! -f "$TARGET_DIR/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg" ]; then
                if [ $(curl -Is "https://il2sturmovik.com/m/articles/$DOWNLOAD_VEHICLE_NAME/$IMG_TYPE.png" | grep 200 | wc -l) -eq 1 ]; then
                    curl -o "$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.png" "https://il2sturmovik.com/m/articles/$DOWNLOAD_VEHICLE_NAME/$IMG_TYPE.png"
                    sips --setProperty format jpeg "$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.png" -o "$TARGET_DIR/images_other/$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.jpg"
                    rm -f "$NEW_VEHICLE_NAME.$LOCAL_IMG_TYPE.png"
                    
                # If there is not Isometric image type, don't try to download other image types
                elif [ "$IMG_TYPE" = "Isometric" ]; then
                    break
                fi
            fi
        done
        
        # Links to each language page of vehicle details
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Links to each language page"
        for IL2_LOCALE in "chs" "eng" "fra" "ger" "rus" "spa"; do
            printf "[ [$IL2_LOCALE]($VEHICLE_TYPE/$NEW_VEHICLE_NAME.$IL2_LOCALE.md) ] " >> "$TARGET_DIR/docs/README.md"
        done
        
        # Main image
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Main image"
        printf "\n\n<table><tbody><tr><td style=\"text-align: center\">" >> "$TARGET_DIR/docs/README.md"
        printf "<a href=\"$GITHUB_RAW_CONTENT/images/$NEW_VEHICLE_NAME.png\"><img src=\"$GITHUB_RAW_CONTENT/images/$NEW_VEHICLE_NAME.png\"></a>" >> "$TARGET_DIR/docs/README.md"
        
        # Generic Pilot Notes
        echo "** $VEHICLE_TYPE $NEW_VEHICLE_NAME Generic Pilot Notes"
        if [ -f "$TARGET_DIR/pilots_notes/$NEW_VEHICLE_NAME.png" ]; then
            printf "</td><td width=\"25%%\" style=\"text-align: center\">" >> "$TARGET_DIR/docs/README.md"
            printf "<a href=\"$GITHUB_RAW_CONTENT/pilots_notes/$NEW_VEHICLE_NAME.png\"><img src=\"$GITHUB_RAW_CONTENT/pilots_notes/$NEW_VEHICLE_NAME.png\"></a>" >> "$TARGET_DIR/docs/README.md"
        fi
        
        printf "</td></tr></tbody></table>\n\n" >> "$TARGET_DIR/docs/README.md"
    done

    # Cleaning
    rm -f "$TARGET_DIR/docs/$VEHICLE_TYPE/\.\!"*
done

# Footer
echo "* Footer"
printf "
## Game Manuals

- Il-2 Great Battles: Operators [ [eng]($GITHUB_RAW_CONTENT/manuals/IL2GB_Operators_Manual_v4702_Release.pdf) ] 
- Il-2 Great Battles: Purchase and Install [ [eng]($GITHUB_RAW_CONTENT/manuals/IL2GB_Purchase_&_Install_Manual_v4702_Release.pdf) ] 
- Il-2 Great Battles: Mission Editor and Multiplayer Server [ [eng]($GITHUB_RAW_CONTENT/manuals/IL-2_Sturmovik_Mission_Editor_and_Multiplayer_Server_Manual.pdf) ] [ [spa]($GITHUB_RAW_CONTENT/manuals/Manual_del_Editor_de_Misiones_y_Servidor_Multijugador.pdf) ] 
- Il-2 Battle of Stalingrad: User Manual [ [eng]($GITHUB_RAW_CONTENT/manuals/IL2_BOS_Manual_English_1011_rev1.pdf) ] [ [spa]($GITHUB_RAW_CONTENT/manuals/IL2_BOS_Manual_Spanish_1011_rev1.pdf) ] 
- Rise of Flight: User Manual [ [eng]($GITHUB_RAW_CONTENT/manuals/ROF_Manual_English_133c_rev1.pdf) ] [ [fra]($GITHUB_RAW_CONTENT/manuals/ROF_Manual_French_133c_rev1.pdf) ] [ [ger]($GITHUB_RAW_CONTENT/manuals/ROF_Manual_German_133c_rev1.pdf) ] [ [rus]($GITHUB_RAW_CONTENT/manuals/ROF_Manual_Russian_133c_rev1.pdf) ] [ [spa]($GITHUB_RAW_CONTENT/manuals/ROF_Manual_Spanish_133c_rev1.pdf) ] 

## Tools

- [ [JSGME Mod Enabler]($GITHUB_RAW_CONTENT/tools/JSGME.zip) ] 
- [ [unGTP-IL2 Extraction Tool]($GITHUB_RAW_CONTENT/tools/unGTP-IL2.zip) ] 

## Credits

- Planes and vehicles specifications texts are taken directly from in-game data of [Il-2 Sturmovik Great Battles](https://il2-series.com).
- Extra images are from https://il2sturmovik.com.
- Pilots Notes of WWII planes are by [lefuneste](https://forum.il2-series.com/profile/214-lefuneste/).
- Pilots Notes of WWI planes are by [Charlo](https://forum.il2-series.com/profile/215-charlo/).
- Cockpits images of WWII planes are from Il-2 Battle of Stalingrad: User Manual and [Luke \"LukeFF\" Wallace](https://forum.il2-series.com/profile/5-lukeff/).
- Cockpits images of WWI planes are from Rise of Flight: User Manual.
- Historical documents are from archive.org, scribd.com and internet forums.

" >> "$TARGET_DIR/docs/README.md"

# Cleaning
rm -rf "./$RAVENSYSTEM_COCKPIT_NOTES_BASENAME"
rm -rf ./planes_notes

echo "FINISHED"
