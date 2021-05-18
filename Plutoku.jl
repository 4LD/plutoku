### A Pluto.jl notebook ###
# v0.14.5

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
	# @bind bindJSudoku SudokuInitial # et son javascript est inclus au dessus
	# styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! ## voir ici, tout en bas ↓
	
	const vivonsPlutoCaché = raw"""<link rel="stylesheet" href="./hide-ui.css">"""
	# ↪ Permet de cacher l'interface de Pluto.jl
	## const vivonsPlutoCaché = "" ## Sinon """<!--commentaire HTML-->"""
	const set19 = Set(1:9) # Pour ne pas le recalculer à chaque fois
	using Random: shuffle! # Astuce pour être encore plus rapide = Fast & Furious
	## shuffle!(x) = x ## Si besoin, mais... Everyday I shuffling ! (dixit LMFAO)

	SudokuMémo=[[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
	[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
	[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]],
	[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]] # En triple pour garder mes initial(e)s ^^
	
	listeJSàmatrice(JSudoku::Vector{Vector{Int}}) = hcat(JSudoku...) #' en pinaillant
	matriceàlisteJS(mat,d=9) = [mat[:,i] for i in 1:d] #I will be back! ## mat3 aussi
	# matriceàlisteJS(listeJSàmatrice(JSudoku)) == JSudoku ## Logique, non ?
	# const JSudokuVide = fill(fill(0,9),9)
		
	kelcarré(i::Int,j::Int) = 1+ 3*div(i-1,3) + div(j-1,3) # n° du carré du sudoku
	carré(i::Int,j::Int)= 1+div(i-1,3)*3:3+div(i-1,3)*3, 1+div(j-1,3)*3:3+div(j-1,3)*3 # permet de fabriquer les filtres pour ne regarder qu'un seul carré
	vues(mat::Array{Int,2},i::Int,j::Int)= (view(mat,i,:), view(mat,:,j), view(mat, carré(i,j)...)) # liste des chiffres possible par lignes, colonnes et carrés
	listecarré(mat::Array{Int,2})= [view(mat,carré(i,j)...) for i in 1:3:9 for j in 1:3:9] # La liste de tous les carrés du sudoku
	chiffrePossible(mat::Array{Int,2},i::Int,j::Int)= setdiff(set19,vues(mat,i,j)...) # Pour une case en i,j
	function chiffrePropal(mat,i,j) # Pour mise en forme en HTML mat3 : 3x3
		cp = chiffrePossible(mat,i,j)
		return matriceàlisteJS(reshape([((i in cp) ? i : 0) for i in 1:9], (3,3)),3)
	end

	function vérifSudokuBon(mat::Array{Int,2})
		lescarrés = listecarré(mat)
		for x in 1:9 # Pour tous les chiffres de 1 à 9...
			for i in 1:9 # ...est-il en doublon dans une ligne ?
				if count(==(x), mat[i,:])>1
					return false
				end
			end
			for j in 1:9 # ...est-il en doublon dans une colonne ?
				if count(==(x), mat[:,j])>1
					return false
				end
			end
			for c in lescarrés # ...est-il en doublon dans un carré ?
				if count(==(x), c)>1
					return false
				end
			end
		end
		return true # Le sudoku semble conforme (mais il peut être impossible)
	end 
	
	# function nbZérosEnLien(listeZéros, clé) 
	#	# une clé pour tous les touchées (bonus :) 
	#	## C'était aussi dans une idée d'optimisation... mais ça faisait perdre du temps ^^
	# 	(itest,jtest) = listeZéros[clé]
	# 	nbZérosVus = 0
	# 	for (i,j) in listeZéros
	# 		if i == itest || j == jtest || kelcarré(i,j)==kelcarré(itest,jtest)
	# 			nbZérosVus +=1
	# 		end
	# 	end
	# 	return nbZérosVus - 1 # pour ne pas s'autocompter
	# end
	function pasAssezDePropal!(listepossibles::Set{Int},dictCheckLi::Dict{Set{Int}, Int},dictCheckCj::Dict{Set{Int}, Int},dictCheckClecarré::Dict{Set{Int}, Int})
	# Ici l'idée est de voir s'il y a plus chiffres à mettre que de cases : en regardant tout ! entre deux cases, trois cases... sur la ligne, colonne, carré ^^
	# Bref, s'il n'y a pas assez de propositions pour les chiffres à caser c'est vrai
		dili = copy(dictCheckLi)
		dico = copy(dictCheckCj)
		dica = copy(dictCheckClecarré)

		for (k,v) in dili # Pour les lignes
			kk = union(k,listepossibles)
			# vv = get(dictCheckClecarré, kkkk, (0,v))[2] #### fausse bonne idée
			if length(kk) > v
				dictCheckLi[kk] = v + 1 # ex: [1,2]=>1 et [2,3]=>1 = [1,2,3]=>2
			else 
				return true
			end
		end	
		for (k,v) in dico # Pour les colonnes
			kk = union(k,listepossibles)
			if length(kk) > v
				dictCheckCj[kk] = v + 1
			else 
				return true
			end
		end	
		for (k,v) in dica # Pour les carrés
			kk = union(k,listepossibles)
			if length(kk) > v
				dictCheckClecarré[kk] = v + 1
			else 
				return true
			end
		end
		get!(dictCheckLi,listepossibles,1)
		get!(dictCheckCj,listepossibles,1)
		get!(dictCheckClecarré,listepossibles,1)
		return false
	end
	function puces(liste, valdéfaut=nothing ; idPuces="p"*string(rand(Int)), classe="")
		début = """<span id="$idPuces" """ *(classe=="" ? ">" : """class="$classe">""")
		fin = """</span><script>const form = document.getElementById('$idPuces')
	form.oninput = (e) => { form.value = e.target.value; """ *
		(idPuces=="CacherRésultat" ? """if (e.target.value=='😉 Cachée') {
		document.getElementById('PossiblesEtSolution').classList.add('pasla');
		} else {
		document.getElementById('PossiblesEtSolution').classList.remove('pasla');
		};""" : "") * """}
							// and bubble upwards
	// set initial value:
	const selected_radio = form.querySelector('input[checked]');
	if(selected_radio != null) {form.value = selected_radio.value;}
	</script>"""
		inputs = ""
		for item in liste
			inputs *= """<span style="display:inline-block;"><input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: O 4px 0 4px;" $(item == valdéfaut ? "checked" : "")><label style="margin: 0 18px 0 2px; user-select: none;" for="$idPuces$item">$item</label></span>"""
		end
		# for (item,valeur) in liste ### si liste::Array{Pair{String,String},1}
		# 	inputs *= """<input type="radio" id="$idPuces$item" name="$idPuces" value="$item" style="margin: 0 4px 0 20px;" $(item == valdéfaut ? "checked" : "")><label for="$idPuces$item">$valeur</label>"""
		# end
		return HTML(début * inputs * fin)
	end

	function htmlSudoku(JSudokuFini,JSudokuini=fill(fill(0,9),9) ; toutVoir=true)
		if isa(JSudokuFini, String)
			return JSudokuFini
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
			  const htmlCell = html`<td class='"""*(toutVoir ? raw"""${isInitial?"norbleu ":""}""" : raw"""${isInitial?"norbleu ":"grandblur blur "}""")*raw"""${isEven?"even-color":"odd-color"}' style='${isMedium?"border-style:solid !important; border-left-width:medium !important;":""}'>${(value||'')}</td>`; // modifié légèrement
			  data[i][j] = value||0;
			  htmlRow.push(htmlCell);
			}
			const isMediumBis = (i%3 === 0);
    		htmlData.push(html`<tr style='${isMediumBis?"border-style:solid !important; border-top-width:medium !important;":""}'>${htmlRow}</tr>`);
		  }
		  const _sudoku = html`<table """*(toutVoir ? "" : raw"""style="user-select: none;" """)*raw""">
			  <tbody>${htmlData}</tbody>
			</table>`  
		  // return {_sudoku,data};
				
				"""*(toutVoir ? "" : raw"""
		let tdbleus = _sudoku.querySelectorAll('td.norbleu');
  		tdbleus.forEach(tdbleu => {
			tdbleu.addEventListener('click', (e) => {
				var grantb = e.target.parentElement.parentElement;
				for(let grani=0; grani<9;grani++){ 
				for(let granj=0; granj<9;granj++){ 
				 if ( !(grantb.childNodes[grani].childNodes[granj].classList.contains("norbleu")) ) {
				grantb.childNodes[grani].childNodes[granj].classList.add("blur");
				
				} }};
			});
		});
		
		let tds = _sudoku.querySelectorAll('td.grandblur');
  		tds.forEach(td => {
				
			td.addEventListener('click', (e) => {
				e.target.classList.toggle("blur");
				
			});
		});	""")*raw"""
				
		  return _sudoku;

		}
		
		// sinon : return createSudokuHtml(...)._sudoku;
		return createSudokuHtml(""" *"$JSudokuFini"*", "*"$JSudokuini"*""");
		</script>""")
		end
	end
	
	function htmlSudokuPropal(JSudokuFini,JSudokuini=fill(fill(0,9),9) ; toutVoir=true, parCase=true)
		if isa(JSudokuFini, String)
			return JSudokuFini
		else
			mS::Array{Int,2} = listeJSàmatrice(JSudokuini)
			mPropal = fill(fill( fill(0,3),3) , (9,9) )
			for i in 1:9, j in 1:9
				if mS[i,j] == 0
					mPropal[i,j] = chiffrePropal(mS, i, j)
				end
			end
			JPropal = matriceàlisteJS(mPropal)
			return HTML(raw"""<script>
		// styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus!
		
		// const kelcarJS = (lig, col) => [Math.floor(lig/3), Math.floor(col/3)];
		const MMcar = (lig, col, lign, colo) => Math.floor(lig/3)==Math.floor(lign/3) && Math.floor(col/3)==Math.floor(colo/3) ;
		
		const createSudokuHtml = (mvalues, values_ini) => {	
		  const data = [];
		  const htmlData = [];
		  for(let i=0; i<9;i++){
			let htmlRow = [];
			data.push([]);
			for(let j=0; j<9;j++){
				
			  	const htmlMiniData = [];
				const isInitial = values_ini[i][j]>0;
				var mini_sudoku = values_ini[i][j];
				if (!(isInitial)) {
				  for(let pl=0; pl<3;pl++){
					let htmlMiniRow = [];
					for(let pj=0; pj<3;pj++){
					const miniValue = mvalues[i][j][pl][pj];
					const htmlMiniCell = html`<td class='mini"""*(toutVoir && parCase ? "'" : raw"""${isInitial?"'":" miniblur blur'"} """)*raw""" data-row="${pl}" data-col="${pj}">${(miniValue||' ')}</td>`; 
					htmlMiniRow.push(htmlMiniCell);
					}
					htmlMiniData.push(html`<tr style="border-style: none !important;">${htmlMiniRow}</tr>`);
				  }
				var mini_sudoku = html`<table class="minitab" """*(toutVoir && parCase ? "" : raw"""style="user-select: none;" """)*raw""">
			  <tbody>${htmlMiniData}</tbody>
			</table>`
				}
			  const valuee = mini_sudoku;
			  const block = [Math.floor(i/3), Math.floor(j/3)];
			  const isEven = ((block[0]+block[1])%2 === 0);
			  const isMedium = (j%3 === 0);
			  const htmlCell = html`<td class='${isInitial?"grandbleu ":""} ${isEven?"even-color":"odd-color"}' style='${isMedium?"border-style:solid !important; border-left-width:medium !important;":""}' data-row="${i}" data-col="${j}">${(valuee||'')}</td>`;
			  data[i][j] = valuee||0;
			  htmlRow.push(htmlCell);
			}
			const isMediumBis = (i%3 === 0);
    		htmlData.push(html`<tr style='${isMediumBis?"border-style:solid !important; border-top-width:medium !important;":""}'>${htmlRow}</tr>`);
		  }
		  const _sudoku = html`<table """*(toutVoir && parCase ? "" : raw"""style="user-select: none;" """)*raw""">
			  <tbody>${htmlData}</tbody>
			</table>`  
			
				"""*(toutVoir && parCase ? "" : raw"""
		let tdbleus = _sudoku.querySelectorAll('td.grandbleu');
  		tdbleus.forEach(tdbleu => {
			tdbleu.addEventListener('click', (e) => {
				var grantb = e.target.parentElement.parentElement;
				for(let grani=0; grani<9;grani++){ 
				for(let granj=0; granj<9;granj++){ 
				 if (grantb.childNodes[grani].childNodes[granj].childNodes[0].childNodes[1]!=null) {
				for(let minii=0; minii<3;minii++){ 
				for(let minij=0; minij<3;minij++){ 
				grantb.childNodes[grani].childNodes[granj].childNodes[0].childNodes[1].childNodes[minii].childNodes[minij].classList.add("blur");
				
				}} } }};
			});
		});
				
		let tds = _sudoku.querySelectorAll('td.miniblur');
  		tds.forEach(td => {
			
			"""*(parCase ? raw"""
			td.addEventListener('click', (e) => {
				e.target.parentElement.parentElement.childNodes.forEach(ligne => {
				  ligne.childNodes.forEach(colo => {
					colo.classList.toggle("blur");
				  });
				}); 
			});	
				""" : (toutVoir ? raw"""	
			td.addEventListener('click', (e) => {
				const ilig = e.target.getAttribute('data-row');
				const jcol = e.target.getAttribute('data-col'); 
					e.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.childNodes.forEach(tr => {
					tr.childNodes.forEach(tdd => {

						if (tdd.childNodes[0].childNodes[1]!=null){
				tdd.childNodes[0].childNodes[1].childNodes[ilig].childNodes[jcol].classList.toggle("blur");
					}});
				});		
			}); """ : raw"""
			
			td.addEventListener('click', (e) => {
				const ilig = e.target.getAttribute('data-row');
				const jcol = e.target.getAttribute('data-col'); 
				const granlig = e.target.parentElement.parentElement.parentElement.parentElement.getAttribute('data-row');
				const grancol = e.target.parentElement.parentElement.parentElement.parentElement.getAttribute('data-col'); 
				const orNicar = (tlig,tcol) => MMcar(granlig,grancol,tlig,tcol);
					e.target.parentElement.parentElement.parentElement.parentElement.parentElement.parentElement.childNodes.forEach(tr => {
					tr.childNodes.forEach(tdd => {

						if (tdd.childNodes[0].childNodes[1]!=null) {
							for(let minii=0; minii<3;minii++){ 
							for(let minij=0; minij<3;minij++){ 
							 if (ilig==minii&&jcol==minij ) {
							tdd.childNodes[0].childNodes[1].childNodes[minii].childNodes[minij].classList.add("blur");
						}}} };

						if ((tdd.childNodes[0].childNodes[1]!=null) && (tdd.getAttribute('data-row') == granlig || tdd.getAttribute('data-col') == grancol || orNicar(tdd.getAttribute('data-row'),tdd.getAttribute('data-col')) )){

							tdd.childNodes[0].childNodes[1].childNodes[ilig].childNodes[jcol].classList.toggle("blur");
							} });
				});		
			}); """))*raw"""
	
		});	""")*raw"""
				
		  return _sudoku;

		}
		
		// sinon : return createSudokuHtml(...)._sudoku;
		return createSudokuHtml(""" *"$JPropal"*", "*"$JSudokuini"*""");
		</script>""")
		end
end
	
######################################################################################
  function résoutSudoku(JSudoku::Vector{Vector{Int}}, nbToursMax::Int = 203, nbEssaisMax::Int = 4, nbEssais::Int = 1) 
	nbTours = 0 # cela compte les tours si choisi bien (avec un léger décalage)
	nbToursTotal = 0 # le nombre qui ce programme a réellement fait par essai
	
	mS::Array{Int,2} = listeJSàmatrice(JSudoku) # Converti en vraie matrice
	lesZéros = shuffle!([(i,j) for i in 1:9, j in 1:9 if mS[i,j]==0])# Fast & Furious
	
	listedechoix = []
	listedancienneMat = []
	# listeHistoChoix = []  ## histoire 0
	# listeHistoMat = []  ## histoire 0
	# nbHistoTot = 0  ## histoire 0
	listedesZéros = []
	listeTours = Int[]
	nbChoixfait = 0
	minChoixdesZéros = 10
	allerAuChoixSuivant = false
	choixPrécédent = false
	choixAfaire = false
	if nbEssais>1 || vérifSudokuBon(mS)
		while length(lesZéros)>0 && nbToursTotal <= nbToursMax
			çaNavancePas = true # Permet de voir si rien ne se remplit en un tour
			minChoixdesZéros = 10
			nbTours += 1
			nbToursTotal += 1
			lesClésZérosàSuppr=Int[]
			vérifligne = [ Dict{Set{Int}, Int}() for _ = 1:9 ]
			vérifcol = [ Dict{Set{Int}, Int}() for _ = 1:9 ]
			vérifcarré = [ Dict{Set{Int}, Int}() for _ = 1:9 ]
			# vérifligne = fill(Set{Int}(),9)
			# vérifcol = fill(Set{Int}(),9)
			# vérifcarré = fill(Set{Int}(),9)
			# nbligne = fill(0,9)
			# nbcol = fill(0,9)
			# nbcarré = fill(0,9)
			if !allerAuChoixSuivant
				for (key, (i,j)) in enumerate(lesZéros)
					listechiffre = chiffrePossible(mS,i,j)
					lecarré = kelcarré(i,j)
					# union!(vérifligne[i],listechiffre)
					# nbligne[i] += 1
					# union!(vérifcol[j],listechiffre)
					# nbcol[j] += 1
					# union!(vérifcarré[lecarré],listechiffre)
					# nbcarré[lecarré] += 1
					if isempty(listechiffre) || (nbEssais>2 && pasAssezDePropal!(listechiffre, vérifligne[i], vérifcol[j], vérifcarré[lecarré]) ) # || length(vérifligne[i]) < nbligne[i] || length(vérifcol[j]) < nbcol[j] || length(vérifcarré[lecarré]) < nbcarré[lecarré] ## || (nbEssais>2 && pasAssezDePropal!(listechiffre, vérifligne[i], vérifcol[j], vérifcarré[lecarré]) ) ### Plus de possibilité (ou pas assez)... pas bon signe ^^
						allerAuChoixSuivant = true # donc mauvais choix
						break
					elseif length(listechiffre) == 1 # L'idéal, une seule possibilité
						mS[i,j]=collect(listechiffre)[1]
						# mS[i,j]=pop!(listechiffre) ## Je ne sais pas :( marche pas
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
						return " ⚡ Sudoku impossible", md"""#### ⚡ Sudoku impossible à résoudre... et à me piéger aussi 😜
							
		Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
		Par exemple : si une case est trop contrainte, qui attend uniquement pour la ligne un 1, et en colonne autre chiffre que 1, comme 9 ← il n'y aura donc aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case : c'est impossible à résoudre... comme ce sudoku initial.""", (tour=nbTours,tt=nbToursTotal,essai=nbEssais,choix=listedechoix,zéro=listedesZéros) #,histChoix=listeHistoChoix,histoMat=listeHistoMat,nbHisto=nbHistoTot)
					elseif choixPrécédent[3] < choixPrécédent[4] # Aller au suivant
						(i,j, choix, l, lc) = choixPrécédent
						# push!(listeHistoMat , copy(mS)) ## histoire 1			
						# push!(listeHistoChoix , choixPrécédent) ## histoire 1
						# nbHistoTot += 1 ## histoire 1
						choixPrécédent = (i,j, choix+1, l, lc)
						listedechoix[nbChoixfait] = choixPrécédent
						mS = copy(listedancienneMat[nbChoixfait])
						nbTours = listeTours[nbChoixfait]
						allerAuChoixSuivant = false
						# mS[i,j] = lc[choix+1]
						mS[i,j] = pop!(lc)
						lesZéros = copy(listedesZéros[nbChoixfait])
					elseif length(listedechoix) < 2 # pas 2 bol
						return " ⚡ Sudoku impossible", md"""#### ⚡ Sudoku impossible à résoudre... et à me piéger aussi 😜
							
		Si ce n'est pas le cas, revérifier le Sudoku initial, car celui-ci n'a pas de solution possible.
							
		Par exemple : si une case est trop contrainte, qui attend uniquement pour la ligne un 1, et en colonne autre chiffre que 1, comme 9 ← il n'y aura donc aucune solution, car on ne peut pas mettre à la fois 1 et 9 dans une seule case : c'est impossible à résoudre... comme ce sudoku initial.""", (tour=nbTours,tt=nbToursTotal,essai=nbEssais,choix=listedechoix,zéro=listedesZéros) #,histChoix=listeHistoChoix,histoMat=listeHistoMat,nbHisto=nbHistoTot)
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
					# push!(listeHistoMat , copy(mS)) ## histoire de		
					# push!(listeHistoChoix , choixAfaire) ## histoire de
					# nbHistoTot += 1 ## histoire 2
					filter!(!=(choixAfaire[1:2]), lesZéros) # On retire ce que l'on a choisi de faire
					push!(listedesZéros , copy(lesZéros)) # copie en dur aussi
					push!(listeTours, nbTours) # On garde tout en mémoire
					nbChoixfait += 1
					# mS[choixAfaire[1:2]...] = choixAfaire[5][1]
					mS[choixAfaire[1:2]...] = pop!(choixAfaire[5])
					choixPrécédent = choixAfaire
				end 
			else # !çaNavancePas && !allerAuChoixSuivant ## Tout va bien ici
				deleteat!(lesZéros, lesClésZérosàSuppr) # On retire ceux remplis
			end	
		end
		else return "🧐 Merci de corriger ce Sudoku ;)", md"""#### 🧐 Merci de revoir ce sudoku, il n'est pas conforme : 
			En effet, il doit y avoir au moins sur une ligne ou colonne ou carré, un chiffre en double; bref au mauvais endroit ! 😄""", (tour=nbTours,tt=nbToursTotal,essai=nbEssais,choix=listedechoix,zéro=listedesZéros) #,histChoix=listeHistoChoix,histoMat=listeHistoMat,nbHisto=nbHistoTot)
	end
	if nbEssais > nbEssaisMax
		return "🤓 Merci de mettre un peu plus de chiffres... sudoku sûrement impossible ;)", md"""#### 🤓 Merci de mettre plus de chiffres ;) 
			
		En effet, bien que ce [Plutoku](https://github.com/4LD/plutoku) est quasi-parfait* 😄, certains cas (très rare bien sûr) peuvent mettre du temps (plus de 3 secondes) que je vous épargne ;)
		
		Il y a de forte chance que votre sudoku soit impossible... sinon, merci de me le signaler, car normalement ce cas arrive moins souvent que gagner au Loto ^^ 
		
		_* Sauf erreur de votre humble serviteur_""", (tour=nbTours,tt=nbToursTotal,essai=nbEssais,choix=listedechoix,zéro=listedesZéros) #,histChoix=listeHistoChoix,histoMat=listeHistoMat,nbHisto=nbHistoTot)
	elseif nbToursTotal > nbToursMax
		return résoutSudoku(JSudoku, nbToursMax+2_345, nbEssaisMax, nbEssais+1) 
	else
		# push!(listeHistoMat , copy(mS)) # toute l'histoire			
		# push!(listeHistoChoix , choixPrécédent) # toute l'histoire
		# nbHistoTot += 1
			
		# return matriceàlisteJS(mS') ## si on utilise : listeJSàmatrice(...)'
		return matriceàlisteJS(mS), md"**Pour résoudre ce sudoku :** il a fallu faire **$nbChoixfait choix** et **$nbTours $((nbTours>1) ? :tours : :tour)** (si on savait à l'avance les bons choix), ce programme ayant fait _**$nbToursTotal $((nbToursTotal>1) ? :tours : :tour) au total**_ en $(nbEssais) $((nbEssais>1) ? :essais : :essai) !!! 😃",(tour=nbTours,tt=nbToursTotal,essai=nbEssais,choix=listedechoix,zéro=listedesZéros) #,histChoix=listeHistoChoix,histoMat=listeHistoMat,nbHisto=nbHistoTot)
	end
  end

# 4LD : Pour pouvoir venir et générer des Sudoku Aléatoire aussi
  function sudokuAléatoireFini() 
	nbTours = 0 # cela compte les tours si choisi bien (avec un léger décalage)
	nbToursTotal = 0 # le nombre qui ce programme a réellement fait
	nbToursMax = 203
	
	mS::Array{Int,2} = zeros(Int, 9,9) # Matrice de zéro
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
	while length(lesZéros)>0 && nbToursTotal < nbToursMax
		çaNavancePas = true # Permet de voir si rien ne se remplit en un tour
		minChoixdesZéros = 10
		nbTours += 1
		nbToursTotal += 1
		lesClésZérosàSuppr=Int[]
		if !allerAuChoixSuivant
			for (key, (i,j)) in enumerate(lesZéros)
				listechiffre = chiffrePossible(mS,i,j)
				if isempty(listechiffre) ### Plus de possibilité (ou pas assez)... pas bon signe ^^
					allerAuChoixSuivant = true # donc mauvais choix
					break
				elseif length(listechiffre) == 1 # L'idéal, une seule possibilité
					mS[i,j]=collect(listechiffre)[1]
					# mS[i,j]=pop!(listechiffre) ## Je ne sais pas :( marche pas
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
				if choixPrécédent[3] < choixPrécédent[4] # Aller au suivant
					(i,j, choix, l, lc) = choixPrécédent
					choixPrécédent = (i,j, choix+1, l, lc)
					listedechoix[nbChoixfait] = choixPrécédent
					mS = copy(listedancienneMat[nbChoixfait])
					nbTours = listeTours[nbChoixfait]
					allerAuChoixSuivant = false
					mS[i,j] = pop!(lc)
					lesZéros = copy(listedesZéros[nbChoixfait])
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
				mS[choixAfaire[1:2]...] = pop!(choixAfaire[5])
				choixPrécédent = choixAfaire
			end 
		else # !çaNavancePas && !allerAuChoixSuivant ## Tout va bien ici
			deleteat!(lesZéros, lesClésZérosàSuppr) # On retire ceux remplis
		end	
	end
	if nbToursTotal > nbToursMax
		return sudokuAléatoireFini() # Normalement, il ne passe peu par ici
	else
		return mS
		# return matriceàlisteJS(mS)
	end
  end
  function sudokuAléatoire(x=19:62, funk=rand, matzéro = sudokuAléatoireFini())
	# x=rand(1:81)) ## Pas besoin d'aller si fort
	if !isa(x, Int) # Permet de choisir le nombre de zéro ou un intervale
		x=funk(x)
	end
	x = (0 < x < 82) ? x : 81 # Pour ceux aux gros doigts, ou qui voit trop grand
	liste = shuffle!([(i,j) for i in 1:9 for j in 1:9])
	for (i,j) in liste[1:x] # nbApproxDeZéros
		matzéro[i,j] = 0
	end
	return matriceàlisteJS(matzéro)
  end

	function vieuxSudoku!(nouveau=sudokuAléatoire(),mémoire=SudokuMémo ; idLien="lien"*string(rand(Int)))
	# function vieuxSudoku!(nouveau=SudokuMémo[3],mémoire=SudokuMémo,sivide=sudokuAléatoire() ; idLien="lien"*string(rand(Int)))
		if isa(nouveau, Int) || isa(nouveau, UnitRange{Int})
			mémoire[2] = sudokuAléatoire(nouveau)
		elseif nouveau==mémoire[1] # Si c'est vide on revient à mon défaut
			# mémoire[2] = copy(mémoire[4])
			mémoire[2] = sudokuAléatoire()
		else mémoire[2] = copy(nouveau) # Astuce pour sauver le sudoku en cours
		end
		return HTML("""<script>
		var ele = document.getElementsByName("ModifierInit");
		for(var ni=0;ni<ele.length;ni++)
			ele[ni].checked = false;
		
		function goSudokuIni() {
			document.getElementsByName("ModifierInit")[1].click();
		}
		document.getElementById("$idLien").addEventListener("click", goSudokuIni);
		goSudokuIni();
		window.location.href = "#ModifierInit";
		</script><h6 style="margin-top: 0;"> Ci-dessous, le bouton ▶ restore le vieux sudoku en sudoku initial ! 🥳 <a id="$idLien" href='#ModifierInit'> retour en haut ↑ </a> </h6>""")
	end
	vieux = vs! = vS! = vieuxSudoku!
	
###### pas besoin de vérifSudokuBon(listeJSàmatrice(sudokuSolution[1])) ##########
######################################################################################
end; #= début du styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! =# #= et https://github.com/fonsp/Pluto.jl/issues/1104 = <link rel="stylesheet" href="./hide-ui.css"> =# HTML(vivonsPlutoCaché * raw"""
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
pluto-output table.minitab {
	border-spacing: 0 !important;
    border: 0 !important;
	// margin: 1px !important;
	margin: auto !important;
}
tr {
  border:0 !important;
  width:0
}

td.even-color{
  // background-color:#fefefe; ci-dessous indentation plus forte = ajout par moi ^^
	background-color:#000;
	text-align:center;
	font-size:14pt;
	width:38px; 
  	height:38px;
	border:1px solid #ccc;
	padding: 0;
}

td.odd-color{
  // background-color:#efefef;
	background-color:#222;
	text-align:center;
	font-size:14pt;
	border:1px solid #ccc;
	width:38px; 
  	height:38px;	
	padding: 0;			  
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
td { min-width: 38px; }

pluto-output table tr td.blur{
	color: transparent;
	user-select: none;
	// filter: blur(5px);
}


td.mini{
	min-width:15px; 
	// height:15px;
	// color: #b39700;
	padding: 0;
}
.minitab tbody tr:nth-child(2n+1) td:nth-child(2n+1) {
	color: #e6c300;
	// 1 3 7 9
}
.minitab tbody tr:nth-child(2n) td:nth-child(2n) {
	color: #e6c300;
	// 5
}
.minitab tbody tr:nth-child(2n+1) td:nth-child(2n) {
	color: #b39700;
	// 2 8
}
.minitab tbody tr:nth-child(2n) td:nth-child(2n+1) {
	color: #b39700;
	// 4 6
}
pluto-output table tr td table tr td.blur{
	// color: unset;
	color: transparent !important;
	// filter: blur(5px);
}

td.grandblur{
}
td.miniblur{
}
td.norbleu{
	font-weight: bold;
	color:#5668a4;
}
td.grandbleu{
	font-weight: bold;
	font-size: 18pt;
	color:#5668a4;
}

input[type="radio" i] {
		margin: 3px 3px 3px 0;
    }
	pluto-output.rich_output,
	div {
		background-color: #000000;
		color: #ded8d8;
	}

	/* div avant Pluto v0.14.5 */
	pluto-output.rich_output,
	.CodeMirror-lines,
	.CodeMirror-linenumber,
	.CodeMirror-gutter-elt,
	.CodeMirror-gutter,
	.CodeMirror-gutters {
		background-color: #000;
		color: #ded8d8;
    	border-right: solid 1px #000;
	}
.pasla{
	// visibility:hidden;
	filter: blur(3px);
}

@media screen and (any-pointer: fine) {
    pluto-cell > pluto-runarea {
        // opacity: 0.5;
        opacity: 0;
        /* to make it feel smooth: */
        transition: opacity 0.25s ease-in-out;
    }
    pluto-cell > pluto-runarea > button:hover,
    pluto-cell:hover > pluto-runarea {
        opacity: 1;
        /* to make it feel snappy: */
        transition: opacity 0.05s ease-in-out;
    }
    pluto-cell > pluto-shoulder > button:hover {
        opacity: 0;
        /* to make it feel snappy: */
        transition: opacity 0.05s ease-in-out;
    }
}

preamble,
pluto-cell:not(.show_input) > pluto-runarea .runcell {
    display: none !important;
}
pluto-cell:not(.show_input) > pluto-runarea,
pluto-cell > pluto-runarea {
    display: block !important;
	background-color: unset;
}
main {
	margin-top: 0;
    padding-bottom: 4rem !important;
}
pluto-shoulder {
	display: block !important;
	// visibility:hidden;
    left: -22px;
	width: 0;
	// width: 22px;
	opacity: 0;
}
pluto-output.rich_output code {
    // padding: 3px;
    // border-radius: 2px;
    // background-color: #e4e4e4;
    background-color: #000;
    // border-top: solid 1px #9b9f9f;
    // border-left: solid 1px #9b9f9f;
	// box-shadow: 2px 2px #9b9f9f;
	// // box-shadow: 0.5px 0.5px 0px 1px #9b9f9f;
    border: solid 1px #9b9f9f;
	color: #9b9f9f;
}
</style>""") # fin du styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! 

# ╔═╡ 96d2d3e0-2133-11eb-3f8b-7350f4cda025
md"# Résoudre un Sudoku par Alexis 😎" # v1.8.1 mardi 18/05/2021 🤟

# Pour la vue HTML et le style CSS, cela est fortement inspiré de https://github.com/Pocket-titan/DarkMode et pour le sudoku https://observablehq.com/@filipermlh/ia-sudoku-ple1
# Pour basculer entre plusieurs champs automatiquement via JavaScript, merci à https://stackoverflow.com/a/15595732 , https://stackoverflow.com/a/44213036 et autres
# Et bien sûr le calepin d'exemple de @fonsp "3. Interactivity"
# Pour info, le code principal et styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus! :)

# Ce "plutoku" est visible sur https://github.com/4LD/plutoku

# Pour le relancer, c'est sur https://mybinder.org/v2/gh/fonsp/pluto-on-binder/master?urlpath=pluto/open?url=https://raw.githubusercontent.com/4LD/plutoku/main/Plutoku.jl
# Ou https://binder.plutojl.org/open?url=https:%252F%252Fraw.githubusercontent.com%252F4LD%252Fplutoku%252Fmain%252FPlutoku.jl

# ╔═╡ 81bbbd00-2c37-11eb-38a2-09eb78490a16
md"""Si besoin, dans cette session, le sudoku en cours (ci-dessous) peut rester en mémoire en cliquant sur le bouton suivant : $(@bind boutonSudokuInitial html"<input type=button style='margin: 0 10px 0 10px;' value='En cours → Le sudoku initial ;)'>") *( si vide → sudoku aléatoire )*"""

# ╔═╡ caf45fd0-2797-11eb-2af5-e14c410d5144
begin 
	boutonSudokuInitial # Remettre le puce "ModifierInit" sur Le sudoku initial ;)
	vieuxSudoku!(SudokuMémo[3]) # Permet de le remplacer par celui modifié
end; md""" $(@bind viderOupas puces(["Vider le sudoku initial","Le sudoku initial ;)"],"Le sudoku initial ;)"; idPuces="ModifierInit")) $(html" <a href='#Bonus' style='padding-left: 10px; border-left: medium dashed #d9d9d9;'>Bonus plus bas ↓</a>") : Revenir à un vieux sudoku
"""

# ╔═╡ a038b5b0-23a1-11eb-021d-ef7de773ef0e
begin
	viderOupas isa Missing ? viderSudoku = 2 : (viderSudoku = (viderOupas == "Vider le sudoku initial" ? 1 : 2))
	SudokuInitial = HTML("""
<script>
// styleCSSpourSudokuCachéEnBasJusteAuDessusDuBonus!

const premier = JSON.stringify( $(SudokuMémo[1]) );
const deuxième = JSON.stringify( $(SudokuMémo[2]) );
const defaultFixedValues = $(SudokuMémo[viderSudoku])""" * raw"""
			
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
	  const isMedium = (j%3 === 0);
      const htmlCell = html`<td class='${isEven?"even-color":"odd-color"}' ${isMedium?'style="border-style:solid !important; border-left-width:medium !important;"':""}>${htmlInput}</td>`
      data[i][j] = value||0;
      htmlRow.push(htmlCell);
    }
	
    const isMediumBis = (i%3 === 0);
    htmlData.push(html`<tr ${isMediumBis?'style="border-style:solid !important; border-top-width:medium !important;"':""}>${htmlRow}</tr>`);
  }
  const _sudoku = html`<table id="sudokincipit" sudata=${JSON.stringify(data)} >
      <tbody>${htmlData}</tbody>
    </table>`  
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
				html.setAttribute('sudata', jdata);
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
		} else if ((val == 0)||(val == 'à')||(val == 'p')||(val == 'P')) {
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
				ele[0].checked = true;
			} else if (jdata == deuxième) {
				ele[1].checked = true;
			}
			html.setAttribute('sudata', jdata);
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
	ele[0].checked = true;
  } else if (jdata == deuxième) {
	ele[1].checked = true; // ...].click(); // était KO...
  }
  html.setAttribute('sudata', jdata);
  html.dispatchEvent(new Event('input'));
  return html;

};

return sudokuViewReactiveValue(createSudokuHtml(defaultFixedValues));
</script>""")
	@bind bindJSudoku SudokuInitial
end

# ╔═╡ 7cce8f50-2469-11eb-058a-099e8f6e3103
md"## Sudoku initial ⤴ (modifiable) et sa solution :"

# ╔═╡ b2cd0310-2663-11eb-11d4-49c8ce689142
bindJSudoku isa Missing ? md"### ... 3, 2, 1 ... le lancement est engagé ! ... 🚀" : (SudokuMémo[3] = bindJSudoku; #= Pour que le sudoku en cours (initial modifié) reste en mémoire si besoin -> Le sudoku initial ;) =# sudokuSolution = résoutSudoku(bindJSudoku); sudokuSolution[2]) # La petite explication seule

# ╔═╡ bba0b550-2784-11eb-2f58-6bca9b1260d0
md"""$(@bind voirOuPas puces(["😉 Cachée", "En touchant, entrevoir les chiffres...","Pour toutes les cases, voir les chiffres..."],"😉 Cachée"; idPuces="CacherRésultat") ) 
$(html"<div style='margin: 2px; border-bottom: medium dashed #262626;'></div>")
                                                
$(@bind PropalOuSoluce puces(["...possibles par chiffre","...possibles par case","...de la solution"],"...possibles par chiffre"; idPuces="PossiblesEtSolution", classe="pasla" ) )"""

# ╔═╡ 4c810c30-239f-11eb-09b6-cdc93fb56d2c
if voirOuPas isa Missing || !@isdefined(sudokuSolution)
	nothing
elseif voirOuPas=="😉 Cachée"
	if typeof(sudokuSolution[1])==String
			md"""⚡ Attention, sudoku initial à revoir ! Aucun résultat à voir 😜 """
	else md"""###### 🤐 Le sudoku est caché pour le moment comme demandé
Bonne chance ! Si besoin, cocher `😉 Cachée` pour revoir ce message .

Pour information, `En touchant, entrevoir les chiffres...` permet en cliquant de faire apparaître (et disparaître via les chiffres bleus) le contenu choisi, comme un coup de pouce. De plus : 

En cliquant précisément dans une case (par exemple, au milieu c'est le chiffre 5), les `...possibles par chiffre` permettent de voir où chaque chiffre est possible dans dans les cases liées (sa ligne, sa colonne et son carré). Les `...possibles par case` permettent de voir l'ensemble des chiffres possibles (d'une ou) des cases cliquées. Seuls les chiffres `...de la solution` montrent (un ou) des chiffres du sudoku fini.

Bien sûr, il y a pour chaque catégorie : 
`Pour toutes les cases, voir les chiffres...` pour les plus grands tricheurs."""
	end
elseif PropalOuSoluce == "...de la solution" # || PropalOuSoluce isa Missing
	htmlSudoku(sudokuSolution[1],bindJSudoku,toutVoir= (voirOuPas=="Pour toutes les cases, voir les chiffres...") )
else htmlSudokuPropal(sudokuSolution[1],bindJSudoku ; toutVoir= (voirOuPas=="Pour toutes les cases, voir les chiffres..."), parCase= (PropalOuSoluce =="...possibles par case") )
end

# ╔═╡ e986c400-60e6-11eb-1b57-97ba3089c8c1
HTML( 
### Vielle astuce pour voir les temps :)
# "<style> pluto-cell > pluto-runarea { opacity: 0.5; } </style>" *
### Maintenant, en cliquant sur les temps tout apparaît ou disparaît ;)
raw"""<script>
function générateurDeCodeClé() {
  var copyText = document.getElementById("pour-définir-le-sudoku-initial");
  var pastext = document.getElementById("sudokincipit");
  copyText.value = 'vieuxSudoku!(' + pastext.getAttribute('sudata') + ')';
  copyText.select();
  navigator.clipboard.writeText(copyText.value); // document.execCommand("copy");
}
document.getElementById("clégén").addEventListener("click", générateurDeCodeClé);
	
var editCSS = document.createElement('style');
document.body.appendChild(editCSS);
var togglé = "0";

let touslestemps = document.getElementsByClassName("runtime");
// touslestemps.forEach( e => { // ne fonctionne pas :'(
for(let j=0; j<(Object.keys(touslestemps).length); j++){
	touslestemps[j].addEventListener("click", (e) => {
		// alert(e.target.classList.toggle("opaqueoupas"));
		togglé = (togglé=="0") ? "0.5" : "0" ;
		editCSS.innerHTML = "pluto-cell > pluto-runarea { opacity: "+ togglé + "; }";
	});
};
</script>
	<h4 id="Bonus">Bonus : garder le sudoku en cours plus tard... </h4>
	<div style="margin-top: 5px;margin-bottom: 5px;">Je conseille de garder le code du sudoku en cours (en cliquant, la copie est automatique ⚡). </div>
	
	<span> → </span><input type=button id="clégén" style='margin-left: 5px;margin-right: 5px;' value="Copier le code à garder :)"><span> ← <strong>Note</strong> : à coller dans un bloc-notes par exemple. </span>
	<input id="pour-définir-le-sudoku-initial" type="text" style='font-size: x-small;' sudokool="[[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0],[0,1,2,3,4,5,0,0,0],[0,2,0,0,3,0,6,0,0],[0,3,4,5,6,0,0,7,0],[0,6,0,0,7,0,8,0,0],[0,7,0,0,8,9,0,0,0],[0,0,0,0,0,0,0,0,0],[0,0,0,0,0,0,0,0,0]]" />
	
	<h4 id="BonusSuite" style="margin-top: 5px;">...et pour retrouver ce vieux sudoku : </h4>
	<div style="margin-top: 5px;">Copier le code souhaité (d'un bloc-notes ou autre, cf. note ci-dessus).</div>
	<div style="margin-top: 3px;">Ensuite, dans une (nouvelle) session, cliquer dans &nbsp;| <i>Enter cell code...</i> |&#xA0; ci-dessous ↓ et coller le code.</div>
	<div style="margin-top: 3px;">Enfin, lancer le code avec le bouton ▶ tout à droite, qui clignote justement. </div>
	<div>Ce vieux sudoku est restoré en place du sudoku initial ! (et automatiquement de <a href='#ModifierInit'>retour en haut ↑</a> ).</div>


	<h6 id="BonusAstuces" style="margin-top: 10px;"> Autres petites astuces :</h6>
	<div> En réalité en dehors de cellule ou de case, le fait de coller (même en <a href='#ModifierInit'>haut</a> de la page) créée une cellule tout en bas (en plus) avec le code. Cela peut faire gagner un peu de temps, et permet de mettre plusieurs vieux sudokus (cependant, seul le dernier, où le bouton ▶ fut appuyé, est pris en compte). </div>
	<div style="margin-top: 3px;">De plus, la fonction <strong>vieuxSudoku!()</strong> sans paramètre permet de générer un sudoku aléatoire. En mettant uniquement un nombre en paramètre, par exemple <strong>vieuxSudoku!(62)</strong> : ce sera le nombre de cases vides du sudoku aléatoire construit. Enfin, en mettant un intervalle, sous la forme <strong>début : fin</strong>, par exemple <strong>vieuxSudoku!(1:81)</strong> : un nombre aléatoire dans cette intervalle sera utilisé. Pour tous ces sudokus aléatoires, le fait de recliquer sur le bouton ▶ en génère un neuf.</div>
""")

# ╔═╡ eb7c97ff-8319-4be9-a879-845c19194122


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
# ╠═eb7c97ff-8319-4be9-a879-845c19194122
