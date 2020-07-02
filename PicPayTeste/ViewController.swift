//
//  ViewController.swift
//  PicPayTeste
//
//  Created by Bruna Fernanda Drago on 02/07/20.
//  Copyright © 2020 Bruna Fernanda Drago. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //Outlets
    @IBOutlet weak var pesquisaSearchBar: UISearchBar!
    @IBOutlet weak var contatoTableView: UITableView!
    
    //Propriedades
     var contatos = [ContatoService]()
    
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Chamando o método que faz o GET na API
        getData()
        
        //Atribuindo o delegate e o datasource
        contatoTableView.delegate = self
        contatoTableView.dataSource = self
    }

//MARK: - Métodos para fazer o GET na API
func getData(){
    
    let urlString = "http://careers.picpay.com/tests/mobdev/users"
    
    guard let url = URL(string: urlString) else{ return}

    URLSession.shared.dataTask(with: url) { (data, response, error) in
        
        guard let data = data else{
            //tratar erro
            return
        }
        do{
            let decoder = JSONDecoder()
            self.contatos = try decoder.decode([ContatoService].self, from: data)
            print(self.contatos)
            
            
        }catch let jsonErr{
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
       return contatos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = contatoTableView.dequeueReusableCell(withIdentifier: "ContatoCell", for: indexPath)as! ContatoCellTableViewCell
        
        cell.nomeLabel.text = contatos[indexPath.row].name
        cell.usernameLabel.text = contatos[indexPath.row].username
        
       return cell
   }
    
    
}
