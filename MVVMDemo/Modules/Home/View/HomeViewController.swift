//
//  HomeViewController.swift
//  MVVMDemo
//
//  Created by Ahmed Emad on 06/09/2023.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    
    let viewModel: HomeViewModelProtocol = HomeViewModel()
    let bag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindingFromViewModelStauts()
        registerTableViewCell()
        subscribePostsViewModel()
        bindToHomeViewModel()
        didSelectItem()
        viewModel.viewDidLoad()
    }
    
    private func bindToHomeViewModel(){
        searchTF.rx.text.orEmpty.bind(to: viewModel.input.searchTextFieldBehavior).disposed(by: bag)
    }

    private func registerTableViewCell(){
        tableView.register(UINib(nibName: String(describing: PostsTableViewCell.self), bundle: nil), forCellReuseIdentifier: String(describing: PostsTableViewCell.self))
    }

    
    private func subscribePostsViewModel(){
        viewModel.output.postsPublish.bind(to: tableView.rx.items(cellIdentifier: String(describing: PostsTableViewCell.self), cellType: PostsTableViewCell.self)){ item, post, cell in
            cell.title.text = post.title
            cell.desc.text = post.des
            
        }.disposed(by: bag)
    }
    
    private func didSelectItem(){
        tableView.rx.modelSelected(PostsModel.self).subscribe(onNext: { post in
            print(post.title)
        }).disposed(by: bag)
    }
    
    
    private func bindingFromViewModelStauts(){
        viewModel.input.binddingStatues.subscribe(onNext: { bindingSTatus in
            switch bindingSTatus {
            case .ShowHud:
                print(" Showing progress hud")
            case .dismissHud:
                print(" dismiss progress hud")
            case .sucessMessage(let message):
                print("sucessMessgae \(message)")
            case .FaluireMessage(let failure):
                print("Failure Message \(failure)")
            case .presentViewController:
                let vc = UIViewController()
                vc.view.backgroundColor = .red
                self.present(vc, animated: true)
            }
        }).disposed(by: bag)
    }
}

