//
//  Translation.swift
//  messagesbeta
//
//  Created by Christopher Trott on 6/14/16.
//  Copyright © 2016 twocentstudios. All rights reserved.
//

import Messages

enum TranslationAnswer: RawRepresentable {
    case known(String)
    case unknown
    
    init?(rawValue: String) {
        switch rawValue {
        case "":
            self = .unknown
        case let rawValue:
            self = .known(rawValue)
        }
    }
    
    var rawValue: String {
        switch self {
        case .unknown:
            return ""
        case .known(let known):
            return known
        }
    }
}

struct Translation {
    var question: String?
    var answer: TranslationAnswer?
    
    var isComplete: Bool {
        return question != nil && answer != nil
    }
}

extension Translation {
    static let questionQueryName = "question"
    static let answerQueryName = "answer"
    
    var questionQueryItem: URLQueryItem? {
        guard let question = question else { return nil }
        return URLQueryItem(name: Translation.questionQueryName, value: question)
    }
    
    var answerQueryItem: URLQueryItem? {
        guard let answer = answer else { return nil }
        return URLQueryItem(name: Translation.answerQueryName, value: answer.rawValue)
    }
}

/**
 Extends `Translation` to be able to be represented by and created with an array of
 `NSURLQueryItem`s.
 */
extension Translation {
    // MARK: Computed properties
    
    var queryItems: [URLQueryItem] {
        var items = [URLQueryItem]()
        
        if let item = questionQueryItem {
            items.append(item)
        }
        if let item = answerQueryItem {
            items.append(item)
        }
        
        return items
    }
    
    // MARK: Initialization
    
    init?(queryItems: [URLQueryItem]) {
        var question: String?
        var answer: TranslationAnswer?
        
        for queryItem in queryItems {
            guard let value = queryItem.value else { continue }
            
            if queryItem.name == Translation.questionQueryName {
                question = value
            } else if let answerType = TranslationAnswer(rawValue: value) where queryItem.name == Translation.answerQueryName {
                answer = answerType
            }
        }
        
        self.question = question
        self.answer = answer
    }
}

extension TranslationAnswer: Equatable {}
func ==(lhs: TranslationAnswer, rhs: TranslationAnswer) -> Bool {
    switch (lhs, rhs) {
    case (.unknown, .unknown):
        return true
    case let (.known(lKnown), .known(rKnown)):
        return lKnown == rKnown
    default:
        return false
    }
}

extension Translation: Equatable {}
func ==(lhs: Translation, rhs: Translation) -> Bool {
    return lhs.question == rhs.question && lhs.answer == rhs.answer
}