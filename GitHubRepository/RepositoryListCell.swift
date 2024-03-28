//
//  RepositoryListCell.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/27/24.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    var repository: Repository? //GitHub API에서 가져올 레포
    
    let nameLabel = UILabel() //repository 이름
    let descriptionLabel = UILabel() //어떤 repo인지 설명
    let starImageView = UIImageView() // 스타 표시 이미지
    let starLabel = UILabel() //얼마나 많은 스타를 받았는지
    let languageLabel = UILabel() // 어떤 언어를 사용했는지
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
           nameLabel, descriptionLabel,
           starImageView, starLabel, languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        guard let repository = repository else {return}
        nameLabel.text = repository.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        descriptionLabel.text = repository.description
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 2
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.text = "\(repository.stargazersCount)"
        starLabel.font = .systemFont(ofSize: 16)
        starLabel.textColor = .gray
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 16)
        languageLabel.textColor = .gray
        
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalTo(nameLabel)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionLabel)
            $0.width.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        starLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        
        languageLabel.snp.makeConstraints {
            $0.centerY.equalTo(starLabel)
            $0.leading.equalTo(starLabel.snp.trailing).offset(12)
        }
        
        
    }
    
}
