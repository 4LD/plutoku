### A Pluto.jl notebook ###
# v0.14.0

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

# ╔═╡ 43ec2840-239d-11eb-075a-071ac0d6f4d4
begin 
	# @bind listeJSudokuDeHTML SudokuInitial # et son javascript est inclus au dessus
	# styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! ## voir ici, tout en bas ↓
	using Random: shuffle! # Astuce pour être encore plus rapide = Fast & Furious
	
	SudokuVideSiBesoin=[[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
						[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]] # En triple pour garder mes initial(e)s ^^
	
	function sudokuInitial!(nouveau=SudokuVideSiBesoin[3],mémoire=SudokuVideSiBesoin ; idLien="lien"*string(rand(Int)))
		if nouveau==mémoire[1] # Si c'est vide on revient à mon défaut
			mémoire[2] = copy(mémoire[4])
		else mémoire[2] = copy(nouveau) # Astuce pour sauver le sudoku en cours
		end
		# return md"""### Le $(html"<a href='#ModifierInit'>sudoku initial</a>") est ainsi restoré ! 🥳 """
		return HTML("""<script>
		var ele = document.getElementsByName("ModifierInit");
		for(var ni=0;ni<ele.length;ni++)
			ele[ni].checked = false;
		
		function goSudokuIni() {
			document.getElementsByName("ModifierInit")[1].click();
		}
		document.querySelector("#$idLien").addEventListener("click", goSudokuIni);
		</script><h3 style="margin-top: 0;"> Le <a id="$idLien" href='#ModifierInit'>sudoku initial</a> est ainsi restoré ! 🥳 </h3>""")
	end
	
	matriceSudoku(listeJSudokuDeHTML) = hcat(listeJSudokuDeHTML...) #' en pinaillant
	matriceàlisteJS(matrice9x9) = [matrice9x9[:,i] for i in 1:9] # I will be back !
	# matriceàlisteJS(matriceSudoku(listeJSudokuDeHTML)) == listeJSudokuDeHTML
	# listeJSudokuDeHTMLavec0 = fill(fill(0,9),9)
		
	kelcarré(lig,col) = 1+ 3*div(lig-1,3) + div(col-1,3) # n° du carré et mat9x9(i,j)
	carré(i,j)= 1+div(i-1,3)*3:3+div(i-1,3)*3, 1+div(j-1,3)*3:3+div(j-1,3)*3 # permet de fabriquer les filtres pour ne regarder qu'un seul carré
	vues(mat,i,j)= (view(mat,i,:), view(mat,:,j), view(mat, carré(i,j)...)) # liste des chiffres possible par lignes, colonnes et carrés
	listecarré(mat)= [view(mat,carré(i,j)...) for i in 1:3:9 for j in 1:3:9] # La liste de tous les carrés du sudoku
	chiffrePossible(mat,i,j)= setdiff(1:9,vues(mat,i,j)...) # Pour une case en i,j

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
	
	function nbZérosEnLien(listeZéros, clé) # une clé pour tous les touchées (bonus :)
		(itest,jtest) = listeZéros[clé]
		nbZérosVus = 0
		for (i,j) in listeZéros
			if i == itest || j == jtest || kelcarré(i,j)==kelcarré(itest,jtest)
				nbZérosVus +=1
			end
		end
		return nbZérosVus - 1 # pour ne pas s'autocompter
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
			inputs *= """<div style="display:inline-block;"><input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: O 4px 0 4px;" $(item == valdéfaut ? "checked" : "")><label style="margin: 0 18px 0 2px;" for="$idPuces$item">$item</label></div>"""
		end
		# for (item,valeur) in liste ### si liste::Array{Pair{String,String},1}
		# 	inputs *= """<input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: 0 4px 0 20px;" $(item == valdéfaut ? "checked" : "")><label for="$idPuces$item">$valeur</label>"""
		# end
		return HTML(début * inputs * fin)
	end

	function htmlSudoku(liste9x9,liste9x9ini=fill(fill(0,9),9) ; toutVoir=true)
		if typeof(liste9x9)==String 
			return liste9x9
		else
			return HTML(raw"""<script>
		// styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus!
				
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
			  const isMedium = (j%3 === 0);
			  const htmlCell = html`<td class='"""*(toutVoir ? "" : raw"""${isInitial?"":"blur"} """)*raw"""${isEven?"even-color":"odd-color"}' style='${isMedium?"border-style:solid !important; border-left-width:medium !important;":""}+${isInitial?"font-weight: bold;color:#5668a4;":""}'>${(value||'')}</td>`; // modifié légèrement
			  data[i][j] = value||0;
			  htmlRow.push(htmlCell);
			}
			const isMediumBis = (i%3 === 0);
    		htmlData.push(html`<tr style='${isMediumBis?"border-style:solid !important; border-top-width:medium !important;":""}'>${htmlRow}</tr>`);
		  }
		  const _sudoku = html`<table """*(toutVoir ? "" : raw"""style="user-select: none;" """)*raw""">
			  <tbody>${htmlData}</tbody>
			</table><br>`  
		  // return {_sudoku,data};
				
				"""*(toutVoir ? "" : raw"""
		let tds = _sudoku.querySelectorAll('td');
  		tds.forEach(td => {
				
			td.addEventListener('click', (e) => {
				e.target.classList.toggle("blur");
				
			});
		});	""")*raw"""
				
		  return _sudoku;

		}
		
		// sinon : return createSudokuHtml(...)._sudoku;
		return createSudokuHtml(""" *"$liste9x9"*", "*"$liste9x9ini"*""");
		</script>""")
		end
	end
	
######################################################################################
  # function trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax = 10_000_000)
  function trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax = 203, nbEssaisMax = 3, nbEssais = 1) 
	nbTours = 0 # cela compte les tours si choisi bien (avec un léger décalage)
	nbToursTotal = 0 # le nombre qui ce programme a réellement fait
	
	mS::Array{Int,2} = matriceSudoku(listeJSudokuDeHTML) # Converti en vraie matrice
	lesZéros = shuffle!([(i,j) for i in 1:9, j in 1:9 if mS[i,j]==0])# Fast & Furious
	
	listedechoix = []
	listedancienneMat = []
	listedesZéros = []
	listeTours = Int[]
	nbChoixfait = 0
	minChoixdesZéros = 10
	allerAuChoixSuivant = false
	choixPrécédent = false
	choixAfaire = false
# 	if listeJSudokuDeHTML==[[1,0,0,0,0,0,0,0,0],[0,2,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]
# 		return ([[1,3,4,2,5,6,7,8,9],[5,2,6,7,8,9,1,3,4],[7,8,9,1,3,4,2,5,6],[2,5,1,3,4,7,9,6,8],[8,6,3,5,9,1,4,2,7],[4,9,7,6,2,8,3,1,5],[3,4,5,8,7,2,6,9,1],[6,7,2,9,1,5,8,4,3],[9,1,8,4,6,3,5,7,2]],md"""**Pour résoudre ce sudoku :** il fallait faire **48 choix** et **24 tours** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement *2 457 708 tours* !!! 
				
# 		... j'ai un peu triché dans cette "IA" (en incluant ce cas) pour vous faire gagner du temps 😄""") ## <- Lenteurs évitées grace à Fast & Furious (cf. plus haut)
	if nbEssais>1 || vérifSudokuBon(mS)
		while length(lesZéros)>0 && nbToursTotal <= nbToursMax
			çaNavancePas = true # Permet de voir si rien ne se remplit en un tour
			minChoixdesZéros = 10
			nbTours += 1
			nbToursTotal += 1
			lesClésZérosàSuppr=Int[]
			vérifligne = fill(Int[],9)
			vérifcol = fill(Int[],9)
			vérifcarré = fill(Int[],9)
			nbligne = fill(0,9)
			nbcol = fill(0,9)
			nbcarré = fill(0,9)
			if !allerAuChoixSuivant
				for (key, (i,j)) in enumerate(lesZéros)
					listechiffre = chiffrePossible(mS,i,j)
					vérifligne[i] = union(vérifligne[i],listechiffre)
					nbligne[i] += 1
					vérifcol[j] = union(vérifcol[j],listechiffre)
					nbcol[j] += 1
					lecarré = kelcarré(i,j)
					vérifcarré[lecarré] = union(vérifcarré[lecarré],listechiffre)
					nbcarré[lecarré] += 1
					if isempty(listechiffre) || length(vérifligne[i]) < nbligne[i] || length(vérifcol[j]) < nbcol[j] || length(vérifcarré[lecarré]) < nbcarré[lecarré] # Plus de possibilité (ou pas assez)... pas bon signe ^^
						allerAuChoixSuivant = true # donc mauvais choix
						break
					elseif length(listechiffre) == 1 # L'idéal, une seule possibilité
						mS[i,j]=listechiffre[1]
						push!(lesClésZérosàSuppr, key)
						çaNavancePas = false # Car on a réussi à remplir
					elseif çaNavancePas && length(listechiffre) < minChoixdesZéros
						minChoixdesZéros = length(listechiffre)
						choixAfaire = (i,j, 1, minChoixdesZéros, listechiffre) # On garde les cellules avec le moins de choix à faire, si ça n'avance pas
					end
				end
			end
			if çaNavancePas || allerAuChoixSuivant # Pour avancer autrement ^^
				if allerAuChoixSuivant # Si le choix en cours n'est pas bon
					if choixPrécédent==false || isempty(listedechoix)# pas de bol hein
						return " ⚡ Sudoku impossible", md"""## ⚡ Sudoku impossible à résoudre... mais impossible de me piéger 😜
							
		Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
		Par exemple : si une case attend uniquement un 1 (en ligne), mais aussi un 9 (en colonne) ← il n'y aura donc aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case : c'est impossible à résoudre... comme ce sudoku initial."""
					elseif choixPrécédent[3] < choixPrécédent[4] # Aller au suivant
						(i,j, choix, l, lc) = choixPrécédent
						choixPrécédent = (i,j, choix+1, l, lc)
						listedechoix[nbChoixfait] = choixPrécédent
						mS = copy(listedancienneMat[nbChoixfait])
						nbTours = listeTours[nbChoixfait]
						allerAuChoixSuivant = false
						mS[i,j] = lc[choix+1]
						lesZéros = copy(listedesZéros[nbChoixfait])
					elseif length(listedechoix) < 2 # pas 2 bol
						return " ⚡ Sudoku impossible", md"""## ⚡ Sudoku impossible à résoudre... mais impossible de me piéger 😜
							
		Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
		Par exemple : si une case attend uniquement un 1 (en ligne), mais aussi un 9 (en colonne) ← il n'y aura donc aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case : c'est impossible à résoudre... comme ce sudoku initial."""
					else # Il faut revenir d'un cran dans la liste historique
						deleteat!(listedechoix, nbChoixfait)
						deleteat!(listedancienneMat, nbChoixfait)
						deleteat!(listedesZéros, nbChoixfait)
						deleteat!(listeTours, nbChoixfait)
						nbChoixfait -= 1
						choixPrécédent = listedechoix[nbChoixfait]
						nbTours = listeTours[nbChoixfait]
					end
				else # Nouveau choix à faire et à garder en mémoire
					push!(listedechoix, choixAfaire) # ici pas besoin de copie
					push!(listedancienneMat , copy(mS)) # copie en dur
					filter!(!=(choixAfaire[1:2]), lesZéros) # On retire ce que l'on a choisi de faire
					push!(listedesZéros , copy(lesZéros)) # copie en dur aussi
					push!(listeTours, nbTours) # On garde tout en mémoire
					nbChoixfait += 1
					mS[choixAfaire[1:2]...] = choixAfaire[5][1]
					choixPrécédent = choixAfaire
				end 
			else # !çaNavancePas && !allerAuChoixSuivant ## Tout va bien ici
				deleteat!(lesZéros, lesClésZérosàSuppr) # On retire ceux remplis
			end	
		end
		else return "🧐 Merci de corriger ce Sudoku ;)", md"""## 🧐 Merci de revoir ce sudoku, il n'est pas conforme : 
			En effet, il doit y avoir au moins sur une ligne ou colonne ou carré, un chiffre en double, ou au mauvais endroit ! 😄"""
	end
	if nbEssais > nbEssaisMax
		return "🤓 Merci de mettre un peu plus de chiffres... sudoku sûrement impossible ;)", md"""## 🤓 Merci de mettre plus de chiffres ;) 
			
		En effet, malgrès le fait que ce [Plutoku](https://github.com/4LD/plutoku) est quasi-parfait* 😄, certains cas (très rare bien sûr) peuvent mettre du temps (moins de 2 minutes) que je vous épargne ;)
		
		Il y a de forte chance que votre sudoku soit impossible... sinon, merci de me le signaler, car normalement ce cas arrive moins souvent que gagner au Loto ^^ 
		
		_* Sauf erreur de votre humble serviteur_"""
	elseif nbToursTotal > nbToursMax
		return trucquirésoudtoutSudoku(listeJSudokuDeHTML, nbToursMax+5_321, nbEssaisMax, nbEssais+1) 
	else
		# return matriceàlisteJS(mS') ## si on utilise : matriceSudoku(...)'
		return (matriceàlisteJS(mS), md"**Pour résoudre ce sudoku :** il a fallu faire **$nbChoixfait choix** et **$nbTours $((nbTours>1) ? :tours : :tour)** (si on savait à l'avance les bons choix), ce programme ayant fait rééllement _**$nbToursTotal $((nbToursTotal>1) ? :tours : :tour) au total**_ en $(nbEssais) $((nbEssais>1) ? :essais : :essai) !!! 😃")
	end
  end
######################################################################################
end; #= début du styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! =# html"""
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
  width:38px !important; 
  height:38px !important;
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

input#pour-définir-le-sudoku-initial,
td input{
  text-align:center;
  font-size:14pt;
  width:100% !important;
  height:100% !important;
  background-color:transparent;
  border:0;
	color:#aaa;
}

.blur{
	color: transparent;
	// filter: blur(5px);
}

</style>""" # fin du styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! 

# ╔═╡ 96d2d3e0-2133-11eb-3f8b-7350f4cda025
md"# Résoudre un Sudoku par Alexis 😎" # v1.6 dimanche 04/04/2021 🔔

# Pour la vue HTML et le style CSS, cela est fortement inspiré de https://github.com/Pocket-titan/DarkMode et pour le sudoku https://observablehq.com/@filipermlh/ia-sudoku-ple1
# Pour basculer entre plusieurs champs automatiquement via JavaScript, merci à https://stackoverflow.com/a/15595732 , https://stackoverflow.com/a/44213036 et autres
# Et bien sûr le calepin d'exemple de @fonsp "3. Interactivity"
# Pour info, le code principal et styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! :)

# Ce "plutoku" est visible sur https://github.com/4LD/plutoku

# Pour le relancer, c'est sur https://mybinder.org/v2/gh/fonsp/pluto-on-binder/master?urlpath=pluto/open?url=https://raw.githubusercontent.com/4LD/plutoku/main/Plutoku.jl

# ╔═╡ 81bbbd00-2c37-11eb-38a2-09eb78490a16
md"""Si besoin dans cette session, le sudoku initial modifié peut rester en mémoire en cliquant sur le bouton suivant : $(@bind boutonSudokuInitial html"<input type=button style='margin-left: 10px;' value='Sudoku initial modifié ;)'>") """

# ╔═╡ caf45fd0-2797-11eb-2af5-e14c410d5144
begin 
	boutonSudokuInitial # Remettre le puce "ModifierInit" sur Le sudoku initial ;)
	sudokuInitial!() # Permet de remplacer le sudoku initial par celui modifié
end; @bind viderOupas puces(["Vider le sudoku initial","Le sudoku initial ;)"],"Le sudoku initial ;)"; idPuces="ModifierInit")

# ╔═╡ a038b5b0-23a1-11eb-021d-ef7de773ef0e
begin
	viderOupas isa Missing ? viderSudoku = 2 : (viderSudoku = (viderOupas == "Vider le sudoku initial" ? 1 : 2))
	SudokuInitial = HTML("""
<script>
// styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus!

const premier = JSON.stringify( $(SudokuVideSiBesoin[1]) );
const deuxième = JSON.stringify( $(SudokuVideSiBesoin[2]) );
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
		// pattern='[0-9]' //// ne fonctionne pas !
        data-row='${i}'
        data-col='${j}'
        maxlength='1' 
        value='${(value||'')}'
      >`;
      const block = [Math.floor(i/3), Math.floor(j/3)];
      const isEven = ((block[0]+block[1])%2 === 0);
	  const isMedium = (j%3 === 0);
      const htmlCell = html`<td class='${isEven?"even-color":"odd-color"}' style='${isMedium?"border-style:solid !important; border-left-width:medium !important;":""}'>${htmlInput}</td>`
      data[i][j] = value||0;
      htmlRow.push(htmlCell);
    }
	
    const isMediumBis = (i%3 === 0);
    htmlData.push(html`<tr style='${isMediumBis?"border-style:solid !important; border-top-width:medium !important;":""}'>${htmlRow}</tr>`);
  }
  const _sudoku = html`<table>
      <tbody>${htmlData}</tbody>
    </table><br>`  
  return {_sudoku,data};
  
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
	
	const daligne = (e) => e.target.getAttribute('data-row');
	const dacol = (e) => e.target.getAttribute('data-col');
	const etp2 = (e) => e.target.parentElement.parentElement;
	const etp3 = (e) => e.target.parentElement.parentElement.parentElement;

	const moveDown = (e) => { 
		if (etp2(e).nextElementSibling == null) { 
		etp3(e).childNodes[0].childNodes[dacol(e)].childNodes[0].focus();
		} else { 
		etp2(e).nextElementSibling.childNodes[dacol(e)].childNodes[0].focus();
		} 
	}
	const moveUp = (e) => {
		if (etp2(e).previousElementSibling == null) { 
		etp3(e).lastChild.childNodes[dacol(e)].childNodes[0].focus();
		} else { 
		etp2(e).previousElementSibling.childNodes[dacol(e)].childNodes[0].focus();
		} 
	}
	const moveLeft = (e) => {
		if (e.target.parentElement.previousElementSibling == null) {
			if (etp2(e).previousElementSibling == null) {
				etp3(e).lastChild.lastChild.childNodes[0].focus();
			} else {
			etp2(e).previousElementSibling.lastChild.childNodes[0].focus();
		} } else {
		e.target.parentElement.previousElementSibling.childNodes[0].focus();
		} 
	}
	const moveRight = (e) => { 
		if (e.target.parentElement.nextElementSibling == null) {
			if (etp2(e).nextElementSibling == null) {
				etp3(e).childNodes[0].childNodes[0].childNodes[0].focus();
			} else {
			etp2(e).nextElementSibling.childNodes[0].childNodes[0].focus();
		} } else { 
		e.target.parentElement.nextElementSibling.childNodes[0].focus();
		} 
	}
		
	input.addEventListener('keydown',(e) => {
	  // e.target.focus();
	  e.target.select();
		
	  switch (e.key) {
		case "ArrowDown":
			moveDown(e);
			break;
		case "ArrowUp":
			moveUp(e);
			break;
		case "ArrowLeft":
			moveLeft(e);
			break;
		case "ArrowRight":
			moveRight(e);
			break;
		case "Shift":
		case "CapsLock":
		case "NumLock":
			break; // https://www.w3.org/TR/uievents-key/#keys-modifier
		case "Backspace":
		case "Delete":
			if (data[daligne(e)][dacol(e)] !== 0) {
				data[daligne(e)][dacol(e)] = 0;
				e.target.value = "";
				// Efface les puces car cela a été touché
				var ele = document.getElementsByName("ModifierInit");
				for(var ni=0;ni<ele.length;ni++)
					ele[ni].checked = false;
				const jdata = JSON.stringify(data);
				if (jdata == premier) {
					ele[0].checked = true;
				} else if (jdata == deuxième) {
					ele[1].checked = true;
				}
				html.dispatchEvent(new Event('input'));
			}
			(e.key==="Delete")?moveRight(e):moveLeft(e);
			var da = document.activeElement;
			(e.key==="Delete")?(da.selectionStart = da.selectionEnd = da.value.length):(da.selectionStart = da.selectionEnd = 0); // select KO :(
			break;
		default:
			return;
		} }) 
		
    input.addEventListener('input',(e) => {
	  const i = e.target.getAttribute('data-row'); // daligne(e)
	  const j = e.target.getAttribute('data-col'); // dacol(e)
	  const val = e.target.value //parseInt(e.target.value);
	  const oldata = data[i][j];

	  const bidouilliste = {a:1,z:2,e:3,r:4,t:5,y:6,u:7,i:8,o:9,
		A:1,Z:2,E:3,R:4,T:5,Y:6,U:7,I:8,O:9,
		'\&':1,é:2,'\"':3,"\'":4,'\(':5,'\-':6,è:7,_:8,ç:9};

	  const androidChromeEstChiant = {'b':moveDown,'B':moveDown,
		'h':moveUp,'H':moveUp,        'j':moveRight,'J':moveRight,
		'g':moveLeft,'G':moveLeft,'v':moveLeft,'V':moveLeft,
		'd':moveRight,'D':moveRight,'n':moveRight,'N':moveRight};

	  if (val in bidouilliste) {
		e.target.value = data[i][j] = bidouilliste[val];
	  } else if (val <= 9 && val >=1) {
		data[i][j] = parseInt(val);
	  } else if (val == 0) {
		data[i][j] = 0;
		e.target.value = '';
	  } else { 
		e.target.value = data[i][j] === 0 ? '' : data[i][j];
	  }

		if (oldata === data[i][j]) {
			e.stopPropagation();
			e.preventDefault();
		} else {
			// Efface les puces car cela a été touché
			var ele = document.getElementsByName("ModifierInit");
			for(var ni=0;ni<ele.length;ni++)
				ele[ni].checked = false;
			const jdata = JSON.stringify(data);
			if (jdata == premier) {
				ele[0].click(); // ele[0].ckecked KO :'(
			} else if (jdata == deuxième) {
				ele[1].click(); // ele[1].ckecked KO :'(
			}
			html.dispatchEvent(new Event('input'));
		}

		if (val in androidChromeEstChiant) {
			androidChromeEstChiant[val](e);
		} else {
			moveRight(e);
		}
		document.activeElement.select();
    })
		
  }) 
	var ele = document.getElementsByName("ModifierInit");
	const jdata = JSON.stringify(data);
		if (jdata == premier) {
			ele[0].click(); // ele[0].ckecked KO :'(
		} else if (jdata == deuxième) {
			ele[1].click(); // ele[1].ckecked KO :'(
		}
  html.dispatchEvent(new Event('input'));
  return html;

};

return sudokuViewReactiveValue(createSudokuHtml(defaultFixedValues));
</script>""")
	@bind listeJSudokuDeHTML SudokuInitial
end

# ╔═╡ 7cce8f50-2469-11eb-058a-099e8f6e3103
md"## Sudoku initial ⤴ (modifiable) et sa solution :"

# ╔═╡ b2cd0310-2663-11eb-11d4-49c8ce689142
listeJSudokuDeHTML isa Missing ? md"### ... 3, 2, 1 ... le lancement est engagé ! ... 🚀" : (SudokuVideSiBesoin[3] = listeJSudokuDeHTML; #= Pour que le sudoku initial modifié reste en mémoire si besoin =# sudokuSolution = trucquirésoudtoutSudoku(listeJSudokuDeHTML); sudokuSolution[2]) # La petite explication

# ╔═╡ bba0b550-2784-11eb-2f58-6bca9b1260d0
 @bind voirOuPas puces(["Cacher le résultat","Entrevoir en touchant","Voir le résultat entier"],"Cacher le résultat"; idPuces="CacherRésultat") ## Par défaut, cela montre la solution, mais on peut cacher

# ╔═╡ 4c810c30-239f-11eb-09b6-cdc93fb56d2c
voirOuPas isa Missing ? nothing : (sudokuRésolu = voirOuPas=="Cacher le résultat" ? (typeof(sudokuSolution[1])==String ? md"""⚡ Attention, sudoku initial à revoir ! Aucun résultat à voir 😜 """ : md"""###### Le sudoku résolu est caché pour le moment comme demandé... 🤐
Bonne chance ! Pour information, "Entrevoir en touchant" permet de faire apparaître (ou disparaître) une case du sudoku à la demande. Enfin... cocher "Voir le résultat entier" pour les tricheurs.""") : htmlSudoku(sudokuSolution[1],listeJSudokuDeHTML,toutVoir=(voirOuPas != "Entrevoir en touchant") ))

# ╔═╡ e986c400-60e6-11eb-1b57-97ba3089c8c1
HTML("""
<script>
function générateurDeCodeClé() {
  var copyText = document.querySelector("#pour-définir-le-sudoku-initial");
  copyText.value = '"""*"sudokuInitial!($listeJSudokuDeHTML)"*"""' ;
  copyText.select();
  document.execCommand("copy");
}
document.querySelector("#clégén").addEventListener("click", générateurDeCodeClé);

function goSudokuIni() {
	document.getElementsByName("ModifierInit")[1].click();
}
document.querySelector("#LienBonus").addEventListener("click", goSudokuIni);
</script>
	<h4 id="Bonus">Bonus : pour garder le sudoku pour plus tard... </h4>
	<div style="margin-top: 5px;">Il est possible de générer un code via le bouton ci-dessous (cela fait même la copie automatique ⚡). </div>
	<div style="margin-top: 2px;margin-bottom: 5px;">Ce code garde le sudoku initial en cours (à coller et sauver dans un bloc-note ou autre). </div>
	
	<span> → </span><input type=button id="clégén" style='margin-left: 5px;margin-right: 5px;' value="Générer le code à garder :)"><span> ← </span>
	<input id="pour-définir-le-sudoku-initial" type="text"/>
	
	<div style="margin-top: 2px;">Ensuite, dans une (nouvelle) session, cliquer sur &nbsp;| <i>Enter cell code...</i> |&#xA0; ci-dessous, puis coller le code dans cette cellule.</div>
	<!--<div style="margin-top: 2px;">Ensuite, dans une (nouvelle) session, cliquer sur &nbsp;| <i>Enter cell code...</i> |&#xA0; ci-dessous, ou créer n'importe quelle cellule via le petit + visible sur le coin en haut à gauche de chaque cellule existante. Puis coller le code dans cette cellule.</div>-->
	<div style="margin-top: 2px;">Enfin lancer le code avec le bouton ▶ tout à droite (qui doit normalement clignoter justement 😉). </div>
	<div style="margin-top: 2px;">Cliquer sur "Le <a id="LienBonus" href="#ModifierInit">sudoku initial</a> ;)" pour revenir ainsi à ce sudoku sauvegardé ! </div>
""")

# ╔═╡ 1c9457f0-60f5-11eb-389f-d79dc5d74b83


# ╔═╡ Cell order:
# ╟─96d2d3e0-2133-11eb-3f8b-7350f4cda025
# ╟─caf45fd0-2797-11eb-2af5-e14c410d5144
# ╟─81bbbd00-2c37-11eb-38a2-09eb78490a16
# ╟─a038b5b0-23a1-11eb-021d-ef7de773ef0e
# ╟─7cce8f50-2469-11eb-058a-099e8f6e3103
# ╟─b2cd0310-2663-11eb-11d4-49c8ce689142
# ╟─bba0b550-2784-11eb-2f58-6bca9b1260d0
# ╟─4c810c30-239f-11eb-09b6-cdc93fb56d2c
# ╟─43ec2840-239d-11eb-075a-071ac0d6f4d4
# ╟─e986c400-60e6-11eb-1b57-97ba3089c8c1
# ╠═1c9457f0-60f5-11eb-389f-d79dc5d74b83
