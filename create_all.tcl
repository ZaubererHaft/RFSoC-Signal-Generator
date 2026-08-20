set project_name "signal-analyzer-pl"

# 1. Offenes Projekt im Speicher schließen (hebt Dateisperren/Locks auf)
if {[current_project -quiet] != ""} {
    puts "INFO: Schließe offenes Projekt im Speicher..."
    close_project
}

# 2. Liste der zu löschenden Vivado-Dateien und -Ordner im Root-Verzeichnis
set files_to_clean [list \
    "${project_name}.xpr" \
    "${project_name}.srcs" \
    "${project_name}.gen" \
    "${project_name}.cache" \
    "${project_name}.hw" \
    "${project_name}.ip_user_files" \
    "${project_name}.sim" \
    ".Xil" \
]

# 3. Gezieltes Löschen der Altlasten
puts "INFO: Starte Bereinigung des Root-Verzeichnisses..."
foreach item $files_to_clean {
    if {[file exists $item]} {
        puts "INFO: Lösche $item..."
        file delete -force $item
    }
}
puts "INFO: Bereinigung abgeschlossen. Starte Projekt-Neuaufbau..."

# 1. Projekt und Block Design aufbauen
source create_project.tcl

# 2. Den Pfad zur .bd-Datei auslesen
set bd_file [get_files *.bd]

# 3. Den HDL-Wrapper generieren (erzeugt die Dateien auf der Festplatte)
make_wrapper -files $bd_file -top

# 4. Suchpfad für den Wrapper dynamisch ermitteln
# (Sucht im .gen-Verzeichnis nach Verilog- oder VHDL-Wrappern)
set wrapper_files [glob -nocomplain ./vivado_project/*.gen/sources_1/bd/*/*_wrapper.[vh]*]

# 5. Fehler abfangen: Datei nur hinzufügen, wenn glob auch etwas gefunden hat
if {[llength $wrapper_files] > 0} {
    puts "INFO: Wrapper gefunden, füge hinzu: $wrapper_files"
    add_files -norecurse [file normalize [lindex $wrapper_files 0]]
} else {
    puts "WARNING: Wrapper-Datei konnte im .gen-Pfad nicht gefunden werden."
    puts "Bitte erzeuge den Wrapper nach dem Öffnen manuell per Rechtsklick im GUI."
}

# 6. Compile-Order aktualisieren
update_compile_order -fileset sources_1

