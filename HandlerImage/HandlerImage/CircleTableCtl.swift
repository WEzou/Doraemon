//
//  CircleTableCtl.swift
//  CircleImageView
//
//  Created by oncezou on 2018/12/7.
//  Copyright © 2018年 oncezw. All rights reserved.
//

import UIKit

class CircleTableCtl: UIViewController {

    let tableview = UITableView()
    let reuseIdentifier = "ImageCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.frame = self.view.bounds
        tableview.delegate = self
        tableview.dataSource = self
        tableview.rowHeight = 50
        tableview.register(ImageCell.self, forCellReuseIdentifier: reuseIdentifier)
        view.addSubview(tableview)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CircleTableCtl: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: reuseIdentifier) as! ImageCell
        cell.setCircleImage("dog", .mask)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
