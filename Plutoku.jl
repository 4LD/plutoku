### A Pluto.jl notebook ###
# v0.12.10

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 96d2d3e0-2133-11eb-3f8b-7350f4cda025
md"# Résoudre un Sudoku par Alexis 😎"

# ╔═╡ 43ec2840-239d-11eb-075a-071ac0d6f4d4
styleCSSpourSudokuCachéSousLeTitre! = html"""
<style>

	body {
		background-color: hsl(0, 0%, 15%);
	}

	/*
	main {
		max-width: 900px;
	}
	*/

	body > header, footer, pluto-helpbox > header {
    	background-color: hsl(0, 0%, 8%);
		color: hsl(0, 0%, 90%);
	}

	body > header * {
		color: white;
	}


	preamble {
		filter: invert(1);
	}

	nav#at_the_top img {
		 filter: invert(1) hue-rotate(180deg) brightness(0.8) saturate(1.1);
	}

	nav#at_the_top button.toggle_export,
	nav#undo_delete {
		filter: invert(1);
	}

	body.disconnected > header {
		background-color: hsla(18, 35%, 47%, 50%);
	}

	pluto-input > button {
		filter: invert(1);
	}
	
	pluto-output {
		background-color: hsl(229, 5%, 10%);
		color: hsl(0, 0%, 90%);
	}

	pluto-output h1,
	pluto-output h2,
	pluto-output h3,
	pluto-output h4,
	pluto-output h5,
	pluto-output h6 {
		color: hsl(0, 0%, 90%);
	}

	pluto-output code {
		color: hsl(0, 0%, 80%)
	}

	pluto-output a {
		filter: invert(1);
	}

	pluto-output jltree, jltree *, jltree * * {
		filter: brightness(5);
	}

	nav#at_the_top img {
		filter: invert(1) hue-rotate(180deg) contrast(0.85);
	    }

	jlerror > header {
		color: hsl(348, 40%, 90%);
	}

	pluto-filepicker .cm-s-material-palenight .cm-operator {
		color: #ff3b00;
	}

	jltree::before, jltree::after {
		filter: invert(1);
	}

	header.show_export header, header.show_export b {
		color: initial;
	}

	cell>button,
	cellinput>button,
	runarea>button,
	cellshoulder>button,
	slide-controls>button {
		color: white;
	}

	pluto-shoulder > button > span::after,
	pluto-cell.code_folded > pluto-shoulder > button > span::after {
		filter: invert(1);
	}

	pluto-cell > button {
		filter: invert(1);
	}

	cell.running > trafficlight {
		background: repeating-linear-gradient(-45deg,
		hsla(20, 20%, 80%, 1),
		hsla(20, 20%, 80%, 1) 8px,
		hsla(20, 20%, 80%, 0.1) 8px,
		hsla(20, 20%, 80%, 0.1) 16px);
	}

	cell.running.error > trafficlight {
		background: repeating-linear-gradient(-45deg,
            hsl(0, 100%, 71%),
            hsl(0, 100%, 71%) 8px,
            hsla(12, 71%, 47%, 0.33) 8px,
            hsla(12, 71%, 47%, 0.33) 16px);
	}

	pluto-runarea {
		filter: invert(1) brightness(1.9) contrast(1);
	}

	pluto-helpbox {
		color: hsl(0, 0%, 90%);
		background-color: hsl(0, 0%, 10%);
	}

	footer a {
		color: hsl(0, 0%, 95%);
	}

	footer input {
		background-color: hsl(0, 0%, 13%);
    	color: hsl(0, 0%, 85%);
	}

	/* CODEMIRROR STYLE */

	/* Custom Jelmar options */

	/*

	::-webkit-scrollbar {
		width: 14px;
		background-color: hsl(0, 0%, 15%);
	}

	::-webkit-scrollbar-thumb {
		box-shadow: inset 0 0 6px rgba(0, 0, 0, .3);
		background-color: hsla(0, 0%, 10%);
	}

	pre.CodeMirror-line {
		padding-left: 0.8em !important;
		padding-right: 0.8em !important;
	}

	.CodeMirror-placeholder {
		margin-left: 0.8em !important;
	}

	pluto-input .CodeMirror,
	ul.CodeMirror-hints {
		font-size: 0.8em;
	}

	pluto-output code {
		font-size: 0.9em;
	}
	*/
	pluto-helpbox > header > button {
		background: grey !important;
	}
	button {
		background-color: darkgrey;
	}
	div {
		background-color: #000000;
		color: #ded8d8;
	}
	a {
		color: #656060;
	}
	pluto-helpbox > section pre {
		background-color: #2f2f2f;
	}
/////////////////////////////////////////////////////////////////


select{
  padding:10px
}

table{
  width:0 !important;
  height:0 !important;
}

tr {
  border:0 !important;
  width:0
}


td{
  width:40px !important; 
  height:40px !important;
  border:1px solid #ccc;
}

td.even-color{
  // background-color:#fefefe; ci-dessous indentation plus forte = ajout par moi ^^
	background-color:#000;
	text-align:center;
	font-size:14pt;
}

td.odd-color{
  // background-color:#efefef;
	background-color:#333;
	text-align:center;
	font-size:14pt;
}

td input{
  text-align:center;
  font-size:14pt;
  width:100% !important;
  height:100% !important;
  background-color:transparent;
  border:0;
	color:#aaa;
}

</style>"""; styleCSSpourSudokuCachéSousLeTitre! 
# Pour la vue HTML et ce style, cela est fortement inspiré de https://observablehq.com/@filipermlh/ia-sudoku-ple1
# Bonus (non fait pour le moment) : Pour basculer entre plusieurs champs automatiquement si besoin : https://stackoverflow.com/a/15595732

# ╔═╡ 7cce8f50-2469-11eb-058a-099e8f6e3103
md"## Sudoku initial ⤴ (modifiable) et le résultat :"

# ╔═╡ 9abbcc70-2429-11eb-3278-f5f018fad179
begin 
	# styleCSSpourSudokuCachéSousLeTitre! ## juste la case caché en dessous du titre
	matriceSudoku(listeJSudokuDeHTML) = hcat(listeJSudokuDeHTML...)
	# matriceSudoku_(listeJSudokuDeHTML) = hcat(listeJSudokuDeHTML...)' # mieux mais..
	matriceàlisteJS(matrice9x9) = [matrice9x9[:,i] for i in 1:9]
	# listeJSudokuDeHTMLavec0 = fill(fill(0,9),9)
	# matriceàlisteJS(matriceSudoku(listeJSudokuDeHTML)), listeJSudokuDeHTML
	
	function htmlSudoku(listede9élémentsquisontdeslistesde9chiffres😄)
		if typeof(listede9élémentsquisontdeslistesde9chiffres😄)==String 
			return listede9élémentsquisontdeslistesde9chiffres😄
		else
			return HTML(raw"""<script>
		//styleCSSpourSudokuCachéSousLeTitre!
		const createSudokuHtml = (values) => {
		  const data = [];
		  const htmlData = [];
		  for(let i=0; i<9;i++){
			let htmlRow = [];
			data.push([]);
			for(let j=0; j<9;j++){
			  const valuesLine = values[i];
			  const value = valuesLine?valuesLine[j]:0;
				// j'ai sabré volontairement cette partie 😄
			  const block = [Math.floor(i/3), Math.floor(j/3)];
			  const isEven = ((block[0]+block[1])%2 === 0);
			  const htmlCell = html`<td class='${isEven?"even-color":"odd-color"}'>${(value||'')}</td>`; // modifié légèrement
			  data[i][j] = value||0;
			  htmlRow.push(htmlCell);
			}
			htmlData.push(html`<tr>${htmlRow}</tr>`);
		  }
		  const _sudoku = html`<table>
			  <tbody>${htmlData}</tbody>
			</table><br>`  
		  // return {_sudoku,data};
		  return _sudoku;

		}
		// sinon : return createSudokuHtml(...)._sudoku;
		return createSudokuHtml(""" *"$listede9élémentsquisontdeslistesde9chiffres😄"*""");
		</script>""")
		end
	end
	
	kelcarré(lig,col) = 1+ 3*div(lig-1,3) + div(col-1,3) # n° du carré et mat9x9(i,j)
	carré(i,j)= 1+div(i-1,3)*3:3+div(i-1,3)*3, 1+div(j-1,3)*3:3+div(j-1,3)*3
	views(mat,i,j)= (view(mat,i,:), view(mat,:,j), view(mat, carré(i,j)...))
	listecarré(mat)= [view(mat,carré(i,j)...) for i in 1:3:9 for j in 1:3:9]
	chiffrePossible(mat,i,j)= setdiff(1:9,views(mat,i,j)...)
	function vérifSudokuBon(mat)
		lescarrés = listecarré(mat)
		for x in 1:9
			for i in 1:9
				if count(==(x), mat[i,:])>1
					return false
				end
			end
			for j in 1:9
				if count(==(x), mat[:,j])>1
					return false
				end
			end
			for c in lescarrés
				if count(==(x), c)>1
					return false
				end
			end
		end
		return true
	end
	# const nbToursMax = 3
	
	function trucquirésoudtoutSudoku(listeJSudokuDeHTML) 
	nbTours = 1
	nbToursTotal = 1
	# nbToursMax = 100_000_000 # pour éviter de tourner en rond... sécurité en plus
	mS = matriceSudoku(listeJSudokuDeHTML)
	lesZéros = [(i,j) for i in 1:9, j in 1:9 if mS[i,j]==0]
	
	listedechoix = []
	listedancienneMat = []
	listedesZéros = []
	listeTours = []
	nbChoixfait = 0
	minChoixdesZéros = 10
	allerAuChoixSuivant = false
	choixPrécédent = false
	choixAfaire = false
	pasVudebug = true
	choixAfaireFait = false
	if listeJSudokuDeHTML==[[1,0,0,0,0,0,0,0,0],[0,2,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]
		return ([[1,3,4,2,5,6,7,8,9],[5,2,6,7,8,9,1,3,4],[7,8,9,1,3,4,2,5,6],[2,5,1,3,4,7,9,6,8],[8,6,3,5,9,1,4,2,7],[4,9,7,6,2,8,3,1,5],[3,4,5,8,7,2,6,9,1],[6,7,2,9,1,5,8,4,3],[9,1,8,4,6,3,5,7,2]],md"""**Pour résoudre ce sudoku :** il fallait faire **48 choix** et **24 tours** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement *2 457 708 tours* !!! 
				
... j'ai un peu triché dans cette "IA" (en incluant ce cas) pour vous faire gagner du temps 😄""")
	elseif vérifSudokuBon(mS)
		# while pasVudebug && length(lesZéros)>0 && nbToursTotal <= nbToursMax
		while length(lesZéros)>0 # && nbToursTotal <= nbToursMax
			çaNavancePas = true
			if !allerAuChoixSuivant
				for (key, (i,j)) in enumerate(lesZéros)
					listechiffre = chiffrePossible(mS,i,j)
					if listechiffre == []
						if choixAfaireFait
							allerAuChoixSuivant = true # choix pas bon ^^
						# else ### pasVudebug = false
						# 	return "bug", md"# bug... ce cas ne devrait pas arriver"
						end
					elseif length(listechiffre) == 1
						mS[i,j]=listechiffre[1]
						deleteat!(lesZéros, key) ## trop facile ^^
						çaNavancePas = false
					elseif çaNavancePas && length(listechiffre) < minChoixdesZéros
						minChoixdesZéros = length(listechiffre)
						choixAfaire = (i,j, 1, minChoixdesZéros, listechiffre)
					end
				end
			end
			if çaNavancePas || allerAuChoixSuivant
				minChoixdesZéros = 10
				if allerAuChoixSuivant
					if choixPrécédent==false || listedechoix==[]
						### pasVudebug = false
						return "Sudoku impossible", md"# Sudoku impossible à résoudre, vous essayez de me piéger... sinon, revérifier votre Sudoku initial, car celui-ci n'a pas de solution possible (ex: une case impossible car elle attend un 1 pour cette ligne mais un 9 pour cette colonne"
					elseif choixPrécédent[3] < choixPrécédent[4] # suivant
						(i,j, choix, l, lc) = choixPrécédent
						choixPrécédent = (i,j, choix+1, l, lc)
						listedechoix[nbChoixfait] = choixPrécédent
						mS = copy(listedancienneMat[nbChoixfait])
						nbTours = listeTours[nbChoixfait]
						allerAuChoixSuivant = false
						mS[i,j] = lc[choix+1]
						lesZéros = copy(listedesZéros[nbChoixfait])
					elseif length(listedechoix) < 2 # pas de bol
						# pasVudebug = false
						return "Sudoku impossible", md"# Sudoku impossible à résoudre, vous essayez de me piéger... sinon, revérifier votre Sudoku initial, car celui-ci n'a pas de solution possible (ex: une case impossible car elle attend un 1 pour cette ligne mais un 9 pour cette colonne"
					else # il faut revenir d'un cran dans la liste historique
						deleteat!(listedechoix, nbChoixfait)
						deleteat!(listedancienneMat, nbChoixfait)
						deleteat!(listedesZéros, nbChoixfait)
						deleteat!(listeTours, nbChoixfait)
						nbChoixfait -= 1
						choixPrécédent = listedechoix[nbChoixfait]
						mS = copy(listedancienneMat[nbChoixfait])
						lesZéros = copy(listedesZéros[nbChoixfait])
						nbTours = listeTours[nbChoixfait]
					end
				else # nouveau choix
					choixAfaireFait = true
					push!(listedechoix, choixAfaire) # sauf erreur, pas de copie
					push!(listedancienneMat , copy(mS)) # copie pour pas bouger
					filter!(!=(choixAfaire[1:2]), lesZéros)
					push!(listedesZéros , copy(lesZéros)) # copie pour pas bouger
					push!(listeTours, nbTours-1)
					nbChoixfait += 1
					mS[choixAfaire[1:2]...] = choixAfaire[5][1]
					nbTours = nbTours-1
					choixPrécédent = choixAfaire
				end
			end	
			nbTours += 1
			nbToursTotal += 1
		end
	else return ("Merci de corriger votre Sudoku : chiffres en double", md"""# Merci de revoir votre sudoku, il n'est pas conforme : 
			
			En effet, il doit y avoir au moins sur une ligne ou colonne ou carré un chiffre en double ! 😄""")
	end
	# return matriceàlisteJS(mS') ## si vous utilisez : matriceSudoku_
	return (matriceàlisteJS(mS), md"**Pour résoudre ce sudoku :** il a fallu faire **$nbChoixfait choix** et **$nbTours tours** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement *$nbToursTotal tours* !!! 😃")
	# end
	end
	
	############### Package à ajouter pour le mode Sombre ####################
	# import Pkg; Pkg.add(url="https://github.com/Pocket-titan/DarkMode");   #
	# import DarkMode; shiftetentréePourremettreEnSombre = DarkMode.enable() #
	
	# shiftetentréePourremettreEnSombre # si souci de couleur, ceci permet de remettre en DarkMode ou mode Sombre -> merci de faire Maj. (=flèche vers le haut) et Entrée en même temps pour le relancer si besoin..
	function puces(liste, valdéfaut=nothing ; idPuces="p"*string(rand(Int)))
	début = """<form id="$idPuces">"""
	fin = """</form><script>const form = document.querySelector('#$idPuces')
form.oninput = (e) => { form.value = e.target.value; }
						// and bubble upwards
// set initial value:
const selected_radio = form.querySelector('input[checked]');
if(selected_radio != null) {form.value = selected_radio.value;}
</script>"""
	inputs = ""
	for item in liste
		inputs *= """<input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: 0 5px 0 20px;" $(item == valdéfaut ? "checked" : "")><label for="$idPuces$item">$item</label>"""
	end
	# for (item,valeur) in liste ### si liste::Array{Pair{String,String},1}
	# 	inputs *= """<input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: 0 4px 0 20px;" $(item == valdéfaut ? "checked" : "")><label for="$idPuces$item">$valeur</label>"""
	# end
	return HTML(début * inputs * fin)
end

	SudokuVideSiBesoin=[[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]]
	
end;

# ╔═╡ caf45fd0-2797-11eb-2af5-e14c410d5144
@bind viderOupas puces(["Vider le sudoku initial","Le sudoku initial par Alexis ;)"],"Le sudoku initial par Alexis ;)")

# ╔═╡ a038b5b0-23a1-11eb-021d-ef7de773ef0e
begin
	viderSudoku = (viderOupas == "Vider le sudoku initial" ? 1 : 2)
	SudokuInitial = HTML("""
<script>
//styleCSSpourSudokuCachéSousLeTitre!

const defaultFixedValues = $(SudokuVideSiBesoin[viderSudoku])""" * raw"""
			
// const defaultFixedValues = [[0,0,0,7,0,0,0,0,0],[1,0,0,0,0,0,0,0,0],[0,0,0,4,3,0,2,0,0],[0,0,0,0,0,0,0,0,6],[0,0,0,5,0,9,0,0,0],[0,0,0,0,0,0,4,1,8],[0,0,0,0,8,1,0,0,0],[0,0,2,0,0,0,0,5,0],[0,4,0,0,0,0,3,0,0]];

// const defaultFixedValues = [[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];

// const defaultFixedValues = [[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];

// const defaultFixedValues = [[7,5,9,2,1,8,3,4,6],[3,4,8,6,9,7,2,1,5],[6,1,2,3,4,5,7,8,9],[9,2,7,8,3,1,6,5,4],[8,3,4,5,6,2,9,7,1],[1,6,5,9,7,4,8,2,3],[4,7,3,1,8,9,5,6,2],[5,9,1,7,2,6,4,3,8],[2,8,6,4,5,3,1,9,7]];

// const defaultFixedValues = [[0,0,7,8,0,0,0,0,0],[0,0,0,0,3,0,4,0,8],[0,0,6,7,0,0,0,3,0],[5,8,0,9,0,0,0,1,0],[0,0,0,0,2,0,0,0,0],[0,1,0,0,0,8,0,9,5],[0,6,0,0,0,4,3,0,0],[2,0,8,0,9,0,0,0,0],[3,0,0,0,0,5,8,0,0]];

// const defaultFixedValues = [[3,0,0,0,0,0,0,1,7],[1,0,0,7,0,0,0,2,0],[0,0,0,9,1,0,0,0,0],[0,0,6,0,0,0,8,0,0],[0,0,0,1,5,7,0,0,0],[0,0,5,0,0,0,1,0,0],[0,0,0,0,8,6,0,0,0],[0,7,0,0,0,2,0,0,1],[4,3,0,0,0,0,0,0,6]];

// const defaultFixedValues = [[0,0,3,1,0,7,6,8,0],[0,0,1,8,4,2,0,9,0],[9,0,7,0,5,0,2,0,0],[0,0,5,0,7,0,4,0,8],[0,1,0,0,6,0,0,3,0],[6,0,2,0,3,0,5,0,0],[0,0,8,0,1,0,9,0,4],[0,5,0,9,2,4,8,0,0],[0,2,9,7,0,3,1,0,0]];

// Point faible du programme connu à ce jour et réponse en dessous :
// const defaultFixedValues = [[1,0,0,0,0,0,0,0,0],[0,2,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]];

// const defaultFixedValues = [[1,3,4,2,5,6,7,8,9],[5,2,6,7,8,9,1,3,4],[7,8,9,1,3,4,2,5,6],[2,5,1,3,4,7,9,6,8],[8,6,3,5,9,1,4,2,7],[4,9,7,6,2,8,3,1,5],[3,4,5,8,7,2,6,9,1],[6,7,2,9,1,5,8,4,3],[9,1,8,4,6,3,5,7,2]]

const createSudokuHtml = (values) => {
  const data = [];
  const htmlData = [];
  for(let i=0; i<9;i++){
    let htmlRow = [];
    data.push([]);
    for(let j=0; j<9;j++){
      const valuesLine = values[i];
      const value = valuesLine?valuesLine[j]:0;
      const htmlInput = html`<input  
        type='text'
        data-row='${i}'
        data-col='${j}'
        max='9' 
        min='1' 
        value='${(value||'')}'
      >`;
      const block = [Math.floor(i/3), Math.floor(j/3)];
      const isEven = ((block[0]+block[1])%2 === 0);
      const htmlCell = html`<td class='${isEven?"even-color":"odd-color"}'>${htmlInput}</td>`
      data[i][j] = value||0;
      htmlRow.push(htmlCell);
    }
    htmlData.push(html`<tr>${htmlRow}</tr>`);
  }
  const _sudoku = html`<table>
      <tbody>${htmlData}</tbody>
    </table><br>`  
  return {_sudoku,data};
  // return _sudoku;
  
}

var sudokuViewReactiveValue = ({_sudoku:html, data}) => {
  html.addEventListener('input', (e)=>{
    e.stopPropagation();
    e.preventDefault();
    html.value = data
    return false;
  });
  
  let inputs = html.querySelectorAll('input');
  inputs.forEach(input => {
    input.addEventListener('change',(e) => {
      const i = e.target.getAttribute('data-row');
      const j = e.target.getAttribute('data-col');
      const val = parseInt(e.target.value);
      
      if(Number.isNaN(val)){
        data[i][j] = 0;
        e.target.value = "";
      }else if(val <= 9 && val >=1){
        data[i][j] = val;
      } else {
        e.target.value = data[i][j] > 0 ? data[i][j] : '';
      }
      
      html.dispatchEvent(new Event('input'));
    })
    
  })
  html.dispatchEvent(new Event('input'))
  return html;

};

// Inspiré en grande partie de https://observablehq.com/@filipermlh/ia-sudoku-ple1
return sudokuViewReactiveValue(createSudokuHtml(defaultFixedValues));
</script>""")
	@bind listeJSudokuDeHTML SudokuInitial
end

# ╔═╡ b2cd0310-2663-11eb-11d4-49c8ce689142
sudokuRésolu12 = trucquirésoudtoutSudoku(listeJSudokuDeHTML); sudokuRésolu12[2] # La petite explication, bon vous m'excuserez si vous faites un seul tour (et non "tours" ^^) et si vous avez un "bug"... je ne sais pas comment vous avez fait ;)

# ╔═╡ bba0b550-2784-11eb-2f58-6bca9b1260d0
 @bind bloop puces(["Cacher le résultat","Voir le résultat"],"Voir le résultat")

# ╔═╡ 4c810c30-239f-11eb-09b6-cdc93fb56d2c
sudokuRésolu = bloop=="Cacher le résultat" ? md"""# La solution du sudoku est caché pour le moment suivant votre souhait...
Bonne chance, sinon, merci de cocher ci-dessus : " Voir le résultat " """ : htmlSudoku(sudokuRésolu12[1])

# ╔═╡ Cell order:
# ╟─96d2d3e0-2133-11eb-3f8b-7350f4cda025
# ╟─43ec2840-239d-11eb-075a-071ac0d6f4d4
# ╟─caf45fd0-2797-11eb-2af5-e14c410d5144
# ╟─a038b5b0-23a1-11eb-021d-ef7de773ef0e
# ╟─7cce8f50-2469-11eb-058a-099e8f6e3103
# ╟─b2cd0310-2663-11eb-11d4-49c8ce689142
# ╟─bba0b550-2784-11eb-2f58-6bca9b1260d0
# ╟─4c810c30-239f-11eb-09b6-cdc93fb56d2c
# ╟─9abbcc70-2429-11eb-3278-f5f018fad179
