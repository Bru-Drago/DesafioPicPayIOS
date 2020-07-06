//
//  ViewController.swift
//  PicPayTeste
//
//  Created by Bruna Fernanda Drago on 02/07/20.
//  Copyright © 2020 Bruna Fernanda Drago. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {

    //Outlets
    @IBOutlet weak var contatoTableView: UITableView!
    
    //Propriedades
     var contatos = [ContatoService]()
     let placeholderImg = UIImage(named: "picpay.png")
    
    //Inicializando searchController com valor nil para que os resultados sejam exibidos na mesma VC
     let searchController = UISearchController(searchResultsController: nil)
     var filteredContatos : [ContatoService] = []
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Chamando o método que faz o GET na API
        getData()
        
        //Atribuindo o delegate e o datasource
        contatoTableView.delegate = self
        contatoTableView.dataSource = self
        
        //Fazendo o setUp da searchBar
        setUpSearchController()
        
    }
    
    //MARK: - Métodos auxiliares
    func showError(){
           
           let alert = UIAlertController(title:"Atenção!", message: "Erro ao carregar as informações ,por favor tente mais tarde!", preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "OK", style: .default))
           
           present(alert, animated: true)
           
       }
    //MARK: - Métodos para a searchController
    
    var isFiltering:Bool{
        return searchController.isActive && !isSearchBarEmpty
    }
    
    //
    func filterContentForSearchText(_ searchText:String){
        filteredContatos = contatos.filter({ (contato:ContatoService) -> Bool in
            return contato.username.lowercased().contains(searchText.lowercased())
        })
        contatoTableView.reloadData()
    }

    //Vai retornar true se a searchBar estiver vazia , e false se estiver preenchida.
    var isSearchBarEmpty:Bool{
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    //Setando a searchController
    func setUpSearchController(){
      
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "A quem você deseja pagar?"
        searchController.searchBar.backgroundColor = .black
        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.layer.cornerRadius = 20
        searchController.searchBar.searchTextField.clipsToBounds = true
        searchController.searchBar.searchTextField.borderStyle = .roundedRect
        //searchController.searchBar.
        searchController.searchBar.showsCancelButton = false
        
        navigationController?.navigationBar.barTintColor = .black
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }


//MARK: - Métodos para fazer o GET na API
func getData(){
    
    let urlString = "http://careers.picpay.com/tests/mobdev/users"
    
    guard let url = URL(string: urlString) else{ return}

    URLSession.shared.dataTask(with: url) { (data, response, error) in
        
        guard let data = data else{
            DispatchQueue.main.async {
                self.showError()
            }
            
            return
        }
        do{
            let decoder = JSONDecoder()
            self.contatos = try decoder.decode([ContatoService].self, from: data)
            print(self.contatos)
            
            
        }catch let jsonErr{
            DispatchQueue.main.async {
                         self.showError()
                     }
            print("Erro no parse do json :\(error?.localizedDescription)")
        }
        DispatchQueue.main.async {
            self.contatoTableView.reloadData()
        }
    } .resume()
        
    }//fim getData
}

//MARK: - Table View Delegate e DataSource
extension ViewController:UITableViewDelegate,UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering{
            return filteredContatos.count
        }
        else{
            return contatos.count
        }
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contatoTableView.dequeueReusableCell(withIdentifier: "ContatoCell", for: indexPath)as! ContatoCellTableViewCell
        
        let contato:ContatoService
        if isFiltering{
            contato = filteredContatos[indexPath.row]
        }else{
            contato = contatos[indexPath.row]
        }
        
        cell.nomeLabel.text = contato.name
        cell.usernameLabel.text = contato.username
        
        //Download e setUp da imagem
        let filteredImg = contato.img
        if let imgURL = URL(string: filteredImg){
            cell.contatoImage.layer.cornerRadius = cell.contatoImage.frame.height / 2
            cell.contatoImage.sd_setImage(with: imgURL, placeholderImage: placeholderImg, options: .highPriority) { (downloadImg, error, cacheType, downloadurl) in
                
                if let error = error{
                    print("Erro no download da imagem :\(error.localizedDescription)")
                }else{
                    print("Download efetuado com sucesso \(downloadurl?.absoluteString)")
                }
            }
        }//fim do if/let
       return cell
   }

    
}
//Este protocolo define o método para atualizar os resultados da pesquisa baseados na informação que o usuário inserir na search bar. 
extension ViewController:UISearchResultsUpdating{
   
    func updateSearchResults(for searchController: UISearchController) {
        
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)

    }
   
}
