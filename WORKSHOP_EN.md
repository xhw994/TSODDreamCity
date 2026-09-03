[h1]↑ If you enjoy this mod, a thumbs up means a lot to me[/h1]
[i]My second mod, for the same novel. Only one city-state this time — but it comes with a city-state category the game doesn't ship with.[/i]
[b]This mod adds Dream City, a city-state from the web novel The Sword of Dawn, along with a brand new city-state category: Entertainment.[/b]

[hr][/hr]
[code]
[h1]City-State: Dream City[/h1]
[h2]Category: Entertainment (a seventh category, added by this mod)[/h2]
Send 1 Envoy: +1 Amenity in the Capital and in every Arena and Ferris Wheel.
Send 3 Envoys: +1 Amenity in every Zoo and Aquarium.
Send 6 Envoys: +1 Amenity in every Stadium and Aquatics Center.

[h2]Suzerain bonus: Narrator Neural Network[/h2]
Eurekas and Inspirations provide an additional 10% of technology and civic costs. Each district in your cities provides +1 Amenity.
[/code]

[hr][/hr]
[h1]About the Entertainment category[/h1]
The base game ships six city-state categories: Scientific, Cultural, Religious, Trade, Industrial and Militaristic. This mod adds a seventh.

That is not as exotic as it sounds — Firaxis did it themselves, adding Maritime city-states in the Indonesia & Khmer scenario. This mod follows the same structure, and shapes the envoy tiers after the expansion-era official categories: the building tier walks along with the envoy tier, rather than the base game's "every district of type X".

Entertainment draws on both the Entertainment Complex and the Water Park building lines, with buildings of the same tier sharing a tier. So a coastal start gets just as much out of it through the Water Park.

[hr][/hr]
[h1]Compatibility[/h1]
Requires the Gathering Storm ruleset.

About that seventh category: the official UI code hardcodes the six (Firaxis left a comment in their own source saying this ought to be database-driven, but presently is not). This mod works around it — it reports an official category outwards and recognises its own city-states by identity instead, so third-party UI mods that switch on the category string will not trip over an unexpected seventh value.

Tested and handled:
[list]
[*] [b]Better City States[/b]: works alongside it. The only effect is that its category-grouped suzerain tally counts Dream City under Cultural.
[*] [b]CIVITAS City-States[/b]: works alongside it, and its Civilopedia page is supported — CIVITAS turned that hardcoded category table into a database-driven one, and this mod registers a row there when it detects it.
[/list]

If another city-state UI overhaul gives you trouble, please report it with your Lua.log.

[hr][/hr]
[h1]Assets[/h1]
The city-state icon (that stick-figure spider) and the cover art are my own. The setting comes from the novel's author, Yuan Tong.

[hr][/hr]
[h1]Credits[/h1]
Thanks to Hemmelfort for the tutorials and tools, to CIVITAS City-States for making the category table database-driven and leaving a way in, and to "Wuthering Waves: Dumpling City-States" for a clean city-state project to read.
