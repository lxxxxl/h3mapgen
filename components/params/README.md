# params

Handles parameters given by the user (usually by gui) and config, producing concrete generation values and initial node for LML phase.

### Obsługa features:

- `WxH` map size: Na razie nie
- Woda (płytka): Na razie nie, ale wysoki priorytet
- Woda (wysoka, wiry): Na razie nie
- Teleporty: Będą
- Warunek zwycięstwa Town Capture: Będzie
- Pozostałe warunki zwycięstwa: Na razie nie (poza graalem zależą od dużo dalszych komponentów)
- Stawianie Graala: Po stronie parametrów chyba zrobię, ale ogólnie to będzie w jakimś późniejszym komponencie



## Input/output specification

Component main function `TODO(h3pgm)` reads map as `h3pgm` table, and modifies it by adding new elements. 


### input 

- `config` - content of user's [config.cfg](../../config.cfg) file
- `userMapParams` - parameters specifying map provided by the user: [detailed specification](#userMapParams-specification)
- `userDetailedParams` - user-provided values overriding (maybe partially) `detailedParams` (but `detailedParams` are always computed to ensure the system is deterministic). Additionally, [`seed`](#seedint) value cannot be override this way.

### output

- `detailedParams` - concretization of `userParameters` (if random inputted) plus additional values computed based on that parameters: [detailed specification](#detailedparams-specification). If user provides non-empty `userDetailedParams`, his values always (except for `seed`) override the generated ones.
- `LML_init` - initial node of the LML graph, containing all classes and map features (see [LML specification](../mlml/README.md))

(Notka: właściwie to jeśli `detailedParams` już w tablicy istnieje to powinno być traktowane jako input, a nie output, bo to znaczy, że user wprowadził dane ręcznie?)

## `userMapParams` specification

Partially based on arrangements pictured [here](../../docs/17.02.01-MapParams-1.jpg).

### `version`:string
_**Map version**: Game version to generate map for._
<details>
  
- `"RoE"` - _Restoration of Erathia_
- `"SoD"` - _Shadow of Death_
</details>

### `seed`:int
_**Generation seed**: Value "0" generates random map, provide other value if you want to reproduce a concrete output._

### `size`:string
_**Map size**: Size of the map._
<details>
  
- `"S"` - _Small (36x36)_
- `"M"` - _Medium (72x72)_
- `"L"` - _Large (108x108)_
- `"XL"` - _Extra Large (144x144)_

(future feature: in theory we can allow any rectangular map size `WxH` smaller then 144x144)
</details>

### `underground`:bool
_**Two level map**: If checked the map will contain an underground level._

### `players`:table
_**Players**: Set the number and specifics of the players._
<details>
  
- _**Castle**: Choose castles available (randomized) for this player, check "random" to set town choosable at the beginning of a game_
- _**Team**: Choose a team number for the player_
- _**Computer only**: Set if the player should be AI only_

`Player = {id:int=1..8, team:int=1..8, computerOnly:bool, castle:table={"Castle", "Tower",...}/{} if in-game random}`
</details>
  
### `winning`:int
_**Winning condition**: The goal of the players._
<details>
  
- `0` - _Random_
- `1` - _Defeat all your enemies_
- `2` - _Capture Town_
- `3` - _Defeat Monster_
- `4` - _Acquire Artifact or Defeat All Enemies_
- `5` - _Build a Grail Structure or Defeat All Enemies_

(możemy się ograniczyć tylko do `1`, ale kurde, dotychczas żaden generator nie pozwalał na pozostałe, a chyba jesteśmy w stanie to zrobić) 
(z kolei z warunkami przegranej proponowałbym nie kombinować)
</details>
  
### `water`:int
_**Water level**: Influences proportion of map covered by the water._
<details>
  
- `0` - _Random_
- `1` - _None_
- `2` - _Low (lakes, seas)_
- `3` - _Standard (continents)_
- `4` - _High (islands)_
</details>
  
### `grail`:bool
_**Grail**: If checked the map will contain Grail._


### `welfare`:int
_**Welfare**: Influences the number of available resources, artifacts, etc._
<details>
  
- `0` - _Random_
- `1` - _Very poor_
- `2` - _Poor_
- `3` - _Medium_
- `4` - _Rich_
- `5` - _Very rich_
</details>
  
### `monsters`:int
_**Monster Strength**: Influences the strength of monsters._
<details>
  
- `0` - _Random_
- `1` - _Very weak_
- `2` - _Weak_
- `3` - _Medium_
- `4` - _Strong_
- `5` - _Very strong_
</details>

### `branching`:int
_**Branching**: Influences the number of available routes between the map zones._
<details>

- `0` - _Random_
- `1` - _All zones contain as small number of entrances as possible_
- `2` - _Most zones contain only minimal number of entrances _
- `3` - _Some zones contain multiple entrances, some not_
- `4` - _Most zones contain multiple entrances _
- `5` - _All zones contain multiple entrances _
</details>
  
### `focus`:int
_**Challenge focus**: Influences the balance between fighting against environment (PvE) and fighting against other players (PvP)._
<details>
  
- `0` - _Random_
- `1` - _Strong PvP_
- `2` - _More PvP_
- `3` - _Balanced_
- `4` - _More PvE_
- `5` - _Strong PvE_
</details>
  
### `transitivity`:int
_**Transitivity**: Influences the number of obstacles and shapes of available paths within the zones._
<details>
  
- `0` - _Random_
- `1` - _Strongly mazelike zones_
- `2` - _More zones containing mazelike style_
- `3` - _Zones containing various styles_
- `4` - _More zones containing open terrain_
- `5` - _Strongly open terrain zones_
</details>
  
### `locations`:int
_**Locations frequency**: Influences the frequency of interactive adventure map locations (universities, arenas, creature banks, swan ponds, etc.)._
<details>
  
- `0` - _Random_
- `1` - _Very rare_
- `2` - _Rare_
- `3` - _Standard_
- `4` - _Common_
- `5` - _Very common_
</details>

### `zonesize`:int
_**Zone size**: Influences the size of an average zone._
<details>
  
- `0` - _Random_
- `1` - _Strongly decreased_
- `2` - _Decreased_
- `3` - _Standard_
- `4` - _Increased_
- `5` - _Strongly increased_

(Jakbyśmy jakoś mocno chcieli to ten parametr można by usunąć)
</details>
  
## `detailedParams` specification

Apart from concretization of `userParameters`, `detailedParams` should contain values directly influencing process of initializing LML (including priorities of some specialized productions!) and other processes in later steps of the generator. However, specifying them directly here allow users to manipulate them easier. Sketch of the influence mapping from `userMapParams` to some of the more detailed map features [here](../../docs/17.02.01-MapParams-2.jpg).

### _param ∈ userMapParams_

All keys given in [`userMapParams`](#usermapparams-specification) are available in `detailedParams`. If user's choice was not _Random_ option, the parameter value is copied. If it was _Random_, its value is randomized over the valid values for this parameter.

There is a special treatment of `players[p].castles` where, if table of length > 1 is provided, the value become string (randomized over the proposed castles). If table length is 0 (in-game random castle), its value in `detailedParams` is `nil`.

After the generation, the values, except `seed`, are overridden by the content of `userDetailedParams` table.

### _playerTowns_:int
_Number of towns owned by the player at the beginning of the game._


### _todo_

- number of zones (all, water, local, buffer)
- levels of zones 
- difficulty (easy, normal, Hard, Expert, Impossible) - as seen by the map editor  (moglibyśmy to dać ustawiać userowi, ale ma chyba wpływ tylko na random obiekty/potwory których raczej nie stawiamy, niech lepiej automatycznie wynika z innych parametrów)
- production priorities
- number of obelisks
- ...


## other notes

- Istnieje masa dodatkowych własności które możemy (chyba raczej w przyszłości) umożliwiać userom do ustawienia. Począwszy od stopnia rozbudowania zamku, zabronionych czarów w gildiach, dopuszczalnych skillach, artefaktach itd (np. tak jak jest to częściowo zrobione [tutaj](http://www.frozenspire.com/MapGenerator/Index.html)). Aczkolwiek proponowałbym, żeby w `detailedParams` były głównie rzeczy które wynikają z `userMapParams`. Co oznacza, że w `config` byłoby miejsce zarówno na dziwne wartości generatora jak liczba kroków generacji, jak i konkretne własności mapy.


