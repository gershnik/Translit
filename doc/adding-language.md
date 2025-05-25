# How to add a new language support

1. Edit [Info.plist](../Translit/Info.plist) template and:
  * Add a new entry under `tsInputModeListKey`. Follow existing entries as templates. 
  * Add a new entry under `tsVisibleInputModeOrderedArrayKey`. (This controls order when multiple 
    languages are selected in UI)
2. Add a new icon for the language with the name you specified in `Info.plist`.
  * Create an icon in [res](../Translit/res/) folder using an existing one as a template
  * **Add it to Xcode project, making sure it is added to `Translit` target**
3. Add a new entry to [InfoPlist.strings](../Translit/res/Base.lproj/InfoPlist.strings)
4. Add a new mappings config `<lang>.toml` in [mappings](../Translit/mappings/) folder.
   The `<lang>` should be the language identifier you set under `TISIntendedLanguage` key you added in `Info.plist`
  * Follow existing files as a template to fill in content
5. Run [generate-tables](../Translit/mappings/generate-tables) script from command line.
6. Build and test
7. Add newly generated table files to source control



