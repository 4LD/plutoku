### A Pluto.jl notebook ###
# v0.12.16

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

# ╔═╡ 9abbcc70-2429-11eb-3278-f5f018fad179
begin 
	SudokuVideSiBesoin=[[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]] # En triple pour garder mes initiales ^^
	
	# styleCSSpourSudokuCachéSousLeTitre! ## juste la case caché en dessous du titre
	using Random: shuffle # Astuce pour être encore plus rapide
	matriceSudoku(listeJSudokuDeHTML) = hcat(listeJSudokuDeHTML...) #' en pinaillant
	matriceàlisteJS(matrice9x9) = [matrice9x9[:,i] for i in 1:9] # I will be back !
	# matriceàlisteJS(matriceSudoku(listeJSudokuDeHTML)) == listeJSudokuDeHTML
	# listeJSudokuDeHTMLavec0 = fill(fill(0,9),9)
		
	kelcarré(lig,col) = 1+ 3*div(lig-1,3) + div(col-1,3) # n° du carré et mat9x9(i,j)
	carré(i,j)= 1+div(i-1,3)*3:3+div(i-1,3)*3, 1+div(j-1,3)*3:3+div(j-1,3)*3 # permet de fabriquer les filtres pour ne regarder qu'un seul carré
	views(mat,i,j)= (view(mat,i,:), view(mat,:,j), view(mat, carré(i,j)...)) # liste des chiffres possible par lignes, colonnes et carrés
	listecarré(mat)= [view(mat,carré(i,j)...) for i in 1:3:9 for j in 1:3:9] # La liste de tous les carrés du sudoku
	chiffrePossible(mat,i,j)= setdiff(1:9,views(mat,i,j)...) # Pour une case en i,j

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

	function htmlSudoku(liste9x9,liste9x9ini=fill(fill(0,9),9) ) # c'est clair
		if typeof(liste9x9)==String 
			return liste9x9
		else
			return HTML(raw"""<script>
		//styleCSSpourSudokuCachéSousLeTitre!
		const createSudokuHtml = (values, values_ini) => {
		  const data = [];
		  const htmlData = [];
		  for(let i=0; i<9;i++){
			let htmlRow = [];
			data.push([]);
			for(let j=0; j<9;j++){
			  const valuesLine = values[i];
			  const value = valuesLine?valuesLine[j]:0;
				const isInitial = values_ini[i][j]>0;
				// j'ai sabré volontairement cette partie 😄
			  const block = [Math.floor(i/3), Math.floor(j/3)];
			  const isEven = ((block[0]+block[1])%2 === 0);
			  const htmlCell = html`<td ${isInitial?"style='font-weight: bold;color:#5668a4'":""} class='${isEven?"even-color":"odd-color"}'>${(value||'')}</td>`; // modifié légèrement
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
		return createSudokuHtml(""" *"$liste9x9"*", "*"$liste9x9ini"*""");
		</script>""")
		end
	end
	
######################################################################################
  # function trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax = 10_000_000)
  function trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax = 1003, nbRécursionsMax = 26, nbRécursions = 0) 
	nbTours = 1 # cela compte les tours si choisi bien (avec un léger décalage)
	nbToursTotal = 1 # le nombre qui ce programme a réellement fait
	
	mS = matriceSudoku(listeJSudokuDeHTML) # Converti en vrai matrice Julia
	lesZéros = shuffle([(i,j) for i in 1:9, j in 1:9 if mS[i,j]==0]) # Fast & Furious
	
	listedechoix = []
	listedancienneMat = []
	listedesZéros = []
	listeTours = []
	nbChoixfait = 0
	minChoixdesZéros = 10
	allerAuChoixSuivant = false
	choixPrécédent = false
	choixAfaire = false
	auMoinsUnChoixFait = false
# 	if listeJSudokuDeHTML==[[1,0,0,0,0,0,0,0,0],[0,2,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]
# 		return ([[1,3,4,2,5,6,7,8,9],[5,2,6,7,8,9,1,3,4],[7,8,9,1,3,4,2,5,6],[2,5,1,3,4,7,9,6,8],[8,6,3,5,9,1,4,2,7],[4,9,7,6,2,8,3,1,5],[3,4,5,8,7,2,6,9,1],[6,7,2,9,1,5,8,4,3],[9,1,8,4,6,3,5,7,2]],md"""**Pour résoudre ce sudoku :** il fallait faire **48 choix** et **24 tours** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement *2 457 708 tours* !!! 
				
# 		... j'ai un peu triché dans cette "IA" (en incluant ce cas) pour vous faire gagner du temps 😄""") ### <-- Vieux bug, évité grace à Fast & Furious (cf. plus haut)
	if vérifSudokuBon(mS)
		while length(lesZéros)>0 && nbToursTotal <= nbToursMax
			çaNavancePas = true # Permet de voir si rien ne se remplit en un tour
			if !allerAuChoixSuivant
				for (key, (i,j)) in enumerate(lesZéros)
					listechiffre = chiffrePossible(mS,i,j)
					if listechiffre == [] # Plus de possibilité... pas bon signe ^^
						if auMoinsUnChoixFait
							allerAuChoixSuivant = true # donc mauvais choix
						end
					elseif length(listechiffre) == 1 # L'idéal, une seule possibilité
						mS[i,j]=listechiffre[1]
						deleteat!(lesZéros, key) # On retire ce qui est traité
						çaNavancePas = false # Car on a réussi à remplir
					elseif çaNavancePas && length(listechiffre) < minChoixdesZéros
						minChoixdesZéros = length(listechiffre)
						choixAfaire = (i,j, 1, minChoixdesZéros, listechiffre) # On garde les cellules avec le moins de choix à faire, si ça n'avance pas
					end
				end
			end
			if çaNavancePas || allerAuChoixSuivant # Il faut avancer autrement ^^
				minChoixdesZéros = 10
				if allerAuChoixSuivant # Si le choix en cours n'est pas bon
					if choixPrécédent==false || listedechoix==[] # pas de bol
						return " ⚡ Sudoku impossible", md"""# ⚡ Sudoku impossible à résoudre... mais impossible de me piéger 😜
							Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
							Par exemple : si une case attend uniquement un 1 (en ligne), mais aussi un 9 (en colonne) ← aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case, c'est donc impossible à résoudre."""
					elseif choixPrécédent[3] < choixPrécédent[4] # Aller au suivant
						(i,j, choix, l, lc) = choixPrécédent
						choixPrécédent = (i,j, choix+1, l, lc)
						listedechoix[nbChoixfait] = choixPrécédent
						mS = copy(listedancienneMat[nbChoixfait])
						nbTours = listeTours[nbChoixfait]
						allerAuChoixSuivant = false
						mS[i,j] = lc[choix+1]
						lesZéros = copy(listedesZéros[nbChoixfait])
					elseif length(listedechoix) < 2 # pas de bol
						return " ⚡ Sudoku impossible", md"""# ⚡ Sudoku impossible à résoudre... mais impossible de me piéger 😜
							Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
							Par exemple : si une case attend uniquement un 1 (en ligne), mais aussi un 9 (en colonne) ← aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case, c'est donc impossible à résoudre."""
					else # Il faut revenir d'un cran dans la liste historique
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
					else # Nouveau choix à faire et à garder en mémoire
					auMoinsUnChoixFait = true
					push!(listedechoix, choixAfaire) # ici pas besoin de copie
					push!(listedancienneMat , copy(mS)) # copie en dur
					filter!(!=(choixAfaire[1:2]), lesZéros) # On retire ce que l'on a choisi de faire
					push!(listedesZéros , copy(lesZéros)) # copie en dur aussi
					push!(listeTours, nbTours-1) # On garde tout en mémoire
					nbChoixfait += 1
					mS[choixAfaire[1:2]...] = choixAfaire[5][1]
					choixPrécédent = choixAfaire
				end
			end	
			nbTours += 1
			nbToursTotal += 1
		end
		else return "🧐 Merci de corriger ce Sudoku ;)", md"""# 🧐 Merci de revoir ce sudoku, il n'est pas conforme : 
			En effet, il doit y avoir au moins sur une ligne, ou colonne, ou carré un chiffre en double ou au mauvais endroit ! 😄"""
	end
	if nbRécursions > nbRécursionsMax
		return "👍 Merci de mettre un peu plus de chiffres ;)", md"""# 👍 Merci de mettre plus de chiffres ;) 
			
			En effet, malgrès le fait que ce *Plutoku* est quasi-parfait 😄, certains cas (assez limités bien sûr) peuvent mettre du temps (moins de 2 minutes) que je vous épargne ;)"""
	elseif nbToursTotal > nbToursMax
		return trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax, nbRécursionsMax, nbRécursions+1) 
	else
		# return matriceàlisteJS(mS') ## si vous utilisez : matriceSudoku_
		return (matriceàlisteJS(mS), md"**Pour résoudre ce sudoku :** il a fallu faire **$nbChoixfait choix** et **$nbTours tours** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement *$nbToursTotal tours* !!! 😃")
	end
  end
######################################################################################
	
end;

# ╔═╡ 96d2d3e0-2133-11eb-3f8b-7350f4cda025
md"# Résoudre un Sudoku par Alexis 😎" # v1.1 lundi 07/12/2020

# ╔═╡ 43ec2840-239d-11eb-075a-071ac0d6f4d4
styleCSSpourSudokuCachéSousLeTitre! = html"""
<style>

/*///////////  Pour Pluto.jl  //////////////*/

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
/*///////////  Pour le sudoku  //////////////*/


select{
  padding:10px
}

table{
  width:0 !important;
  height:0 !important;
}
pluto-output table {
    border: medium hidden #000 !important;
}

tr {
  border:0 !important;
  width:0
}


td{
  width:40px !important; 
  height:40px !important;
  border:1px solid #ccc;
  padding: 0 !important;
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
# Pour la vue HTML et ce style, cela est fortement inspiré de https://github.com/Pocket-titan/DarkMode et pour le sudoku https://observablehq.com/@filipermlh/ia-sudoku-ple1
# Pour basculer entre plusieurs champs automatiquement via JavaScript, merci à https://stackoverflow.com/a/15595732
# Ce "plutoku" est visible sur https://github.com/4LD/plutoku
# Pour le relancer, c'est sur https://mybinder.org/v2/gh/fonsp/pluto-on-binder/master?urlpath=pluto/open?url=https://raw.githubusercontent.com/4LD/plutoku/main/Plutoku.jl

# ╔═╡ 81bbbd00-2c37-11eb-38a2-09eb78490a16
md"""Si besoin dans cette session, le sudoku initial (modifié ou non) peut rester en mémoire en cliquant sur le bouton suivant : $(@bind boutonSudokuInitial html"<input type=button style='margin-left: 10px;' value='Sudoku initial à garder ;)'>") """

# ╔═╡ caf45fd0-2797-11eb-2af5-e14c410d5144
begin 
	boutonSudokuInitial # Permet de remplacer le sudoku initial par celui gardé
	if SudokuVideSiBesoin[3]==SudokuVideSiBesoin[1]
		SudokuVideSiBesoin[2] = copy(SudokuVideSiBesoin[4])
	else SudokuVideSiBesoin[2] = copy(SudokuVideSiBesoin[3]) # Astuce pour basculer
	end
end; @bind viderOupas puces(["Vider le sudoku initial","Le sudoku initial ;)"],"Le sudoku initial ;)"; idPuces="ModifierInit")

# ╔═╡ a038b5b0-23a1-11eb-021d-ef7de773ef0e
begin
	viderSudoku = (viderOupas == "Vider le sudoku initial" ? 1 : 2)
	SudokuInitial = HTML("""
<script>
//styleCSSpourSudokuCachéSousLeTitre!

const defaultFixedValues = $(SudokuVideSiBesoin[viderSudoku])""" * raw"""
			
// const defaultFixedValues = [[0,0,0,7,0,0,0,0,0],[1,0,0,0,0,0,0,0,0],[0,0,0,4,3,0,2,0,0],[0,0,0,0,0,0,0,0,6],[0,0,0,5,0,9,0,0,0],[0,0,0,0,0,0,4,1,8],[0,0,0,0,8,1,0,0,0],[0,0,2,0,0,0,0,5,0],[0,4,0,0,0,0,3,0,0]];

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
        maxlength='1' 
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
      const val = e.target.value //parseInt(e.target.value);
      
      if(Number.isNaN(val)){
        data[i][j] = 0;
        e.target.value = "";
      }else if(val <= 9 && val >=1){
        data[i][j] = parseInt(val);
      } else {
		data[i][j] = 0;
        e.target.value = "";
        // e.target.value = data[i][j] > 0 ? data[i][j] : '';
      }
      
      html.dispatchEvent(new Event('input'));
    })
    
		
		// Ajout par Alexis // retour // avancer en mettant des lettres ;)
	input.addEventListener('keyup',(e) => {
		
		//var target = e.srcElement || e.target;
		var target = e.target;
    	var maxLength = 1; //parseInt(target.attributes["maxlength"].value, 10);
    var myLength = target.value.length;
    if (myLength >= 1) {
        if (e.target.parentElement.nextElementSibling == null) {
		var next = e.target.parentElement.parentElement.nextElementSibling.childNodes[0].childNodes[0]
		} else {
		var next = e.target.parentElement.nextElementSibling.childNodes[0]
		}
		next.focus();
    }
    // Move to previous field if empty (user pressed backspace)
    else if (myLength === 0) {
        if (e.target.parentElement.previousElementSibling == null) {
		var préc = e.target.parentElement.parentElement.previousElementSibling.lastChild.childNodes[0]
		} else {
		var préc = e.target.parentElement.previousElementSibling.childNodes[0]
		}
		préc.selectionStart = préc.selectionEnd = préc.value.length;
		préc.focus();
		
    }
		})
		
		
  })
  html.dispatchEvent(new Event('input'))
  return html;

};

// Inspiré cf. styleCSSpourSudokuCachéSousLeTitre!
return sudokuViewReactiveValue(createSudokuHtml(defaultFixedValues));
</script>""")
	@bind listeJSudokuDeHTML SudokuInitial
end

# ╔═╡ 7cce8f50-2469-11eb-058a-099e8f6e3103
md"## Sudoku initial ⤴ (modifiable) et sa solution :"

# ╔═╡ b2cd0310-2663-11eb-11d4-49c8ce689142
SudokuVideSiBesoin[3] = listeJSudokuDeHTML; sudokuRésolu12 = trucquirésoudtoutSudoku(listeJSudokuDeHTML); sudokuRésolu12[2] # La petite explication, bon vous m'excuserez si vous faites un seul tour (et non "tours" ^^) et si vous avez un "bug"... je ne sais pas comment vous avez fait ;)

# ╔═╡ bba0b550-2784-11eb-2f58-6bca9b1260d0
 @bind voirOuPas puces(["Cacher le résultat","Voir le résultat"],"Voir le résultat"; idPuces="CacherRésultat")

# ╔═╡ 4c810c30-239f-11eb-09b6-cdc93fb56d2c
sudokuRésolu = voirOuPas=="Cacher le résultat" ? (typeof(sudokuRésolu12[1])==String ? md"""# 🤐 Le sudoku résolu est caché pour le moment comme demandé...
⚡ Attention, sudoku initial à revoir ! Même " Voir le résultat " ne le donnera pas 😜 """ : md"""# 🤐 Le sudoku résolu est caché pour le moment comme demandé...
Bonne chance ! Sinon, merci de recocher ci-dessus : " Voir le résultat " """) : htmlSudoku(sudokuRésolu12[1],listeJSudokuDeHTML)

# ╔═╡ Cell order:
# ╟─96d2d3e0-2133-11eb-3f8b-7350f4cda025
# ╟─43ec2840-239d-11eb-075a-071ac0d6f4d4
# ╟─caf45fd0-2797-11eb-2af5-e14c410d5144
# ╟─81bbbd00-2c37-11eb-38a2-09eb78490a16
# ╟─a038b5b0-23a1-11eb-021d-ef7de773ef0e
# ╟─7cce8f50-2469-11eb-058a-099e8f6e3103
# ╟─b2cd0310-2663-11eb-11d4-49c8ce689142
# ╟─bba0b550-2784-11eb-2f58-6bca9b1260d0
# ╟─4c810c30-239f-11eb-09b6-cdc93fb56d2c
# ╟─9abbcc70-2429-11eb-3278-f5f018fad179
