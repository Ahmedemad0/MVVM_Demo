//
//  HomeViewModel.swift
//  MVVMDemo
//
//  Created by Ahmed Emad on 06/09/2023.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModel: AnyObject {
    associatedtype Input
    associatedtype Output
}

protocol HomeViewModelProtocol: AnyObject {
    var input: HomeViewModel.Input { get }
    var output: HomeViewModel.Output { get }
    func viewDidLoad()
}

enum HomeBinding {
    case ShowHud
    case dismissHud
    case sucessMessage(String)
    case FaluireMessage(String)
    case presentViewController
}

class HomeViewModel: HomeViewModelProtocol, ViewModel {
    
    
    class Input {
        var searchTextFieldBehavior: BehaviorRelay<String> = .init(value: "")
        var binddingStatues: PublishSubject<HomeBinding> = .init()
    }
    
    
    class Output {
        var postsPublish: PublishSubject<[PostsModel]> = .init()
    }
    private var bag = DisposeBag()
    private var allCollectedPostsPublish: PublishSubject<[PostsModel]> = .init()
    
    var input: Input = .init()
    var output: Output = .init()
        
    func viewDidLoad(){
        handlePostsSearchOutput()
        getPostsFromApi()
    }
    
    private func getPostsFromApi(){
        
        input.binddingStatues.onNext(.ShowHud)
        let postsModels: [PostsModel] = [
            .init(title: "TITLE 1", des: "DESC 1"),
            .init(title: "TITLE 2", des: "DESC 2"),
            .init(title: "TITLE 3", des: "DESC 3"),
            .init(title: "TITLE 4", des: "DESC 4"),
            .init(title: "TITLE 5", des: "DESC 5"),
        ]
        self.allCollectedPostsPublish.onNext(postsModels)
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.input.binddingStatues.onNext(.presentViewController)
        }
        
    }
    
    private func handlePostsSearchOutput(){
        Observable.combineLatest(allCollectedPostsPublish, input.searchTextFieldBehavior)
            .map { posts, search in
                if search == ""  {return posts}
                return posts.filter {$0.title.lowercased().contains(search.lowercased())}
            }.bind(to: output.postsPublish).disposed(by: bag)
    }
}
