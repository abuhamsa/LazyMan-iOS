//
//  GameManager.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 3/3/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import Foundation
import SwiftyJSON
import Pantomime

class GameManager
{
    static let manager = GameManager()
    
    private var nhlGames = [String : [Game]]()
    private var mlbGames = [String : [Game]]()
    
    private let formatter = DateFormatter()
    private let gmtFormatter = DateFormatter()
    
    private let nhlFormatURL = "https://statsapi.web.nhl.com/api/v1/schedule?date=%@&expand=schedule.teams,schedule.linescore,schedule.game.content.media.epg"
    private let mlbFormatURL = "https://statsapi.mlb.com/api/v1/schedule?sportId=1&date=%@&hydrate=team,linescore,game(content(summary,media(epg)))&language=en"
    
    init()
    {
        self.formatter.dateFormat = "yyyy-MM-dd"
        
        self.gmtFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        self.gmtFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        self.gmtFormatter.locale = Locale(identifier: "en_US_POSIX")
    }
    
    func getGames(date: Date, league: League) -> [Game]?
    {
        switch league
        {
        case .NHL:
            return self.nhlGames[self.formatter.string(from: date)]
            
        case .MLB:
            return self.mlbGames[self.formatter.string(from: date)]
        }
    }
    
    func reloadGames(date: Date, league: League, completion: (([Game]) -> ())?, error: ((String) -> ())?)
    {
        switch league
        {
        case .NHL:
            self.getNHLGames(date: self.formatter.string(from: date), completion: completion, errorCompletion: error)
            
        case .MLB:
            self.getMLBGames(date: self.formatter.string(from: date), completion: completion, errorCompletion: error)
        }
    }
    
    private func getNHLGames(date: String, completion: (([Game]) -> ())?, errorCompletion: ((String) -> ())?)
    {
        let nhlStatsURL = String(format: self.nhlFormatURL, date)
        
        var newGames: [Game] = []
        
        DispatchQueue.global(qos: .utility).async {

        if let url = URL(string: nhlStatsURL)
        {
            let config = URLSessionConfiguration.default
            config.requestCachePolicy = .reloadIgnoringLocalCacheData
            config.urlCache = nil
            
            let session = URLSession.init(configuration: config)
            
            
            session.dataTask(with: url, completionHandler: { (data, response, error) in
            
//            let file = Bundle.main.path(forResource: "schedule2018-04-05", ofType: "json")
//            let data = try? Data(contentsOf: URL(fileURLWithPath: file!))
            
                let j = try! JSON(data: data!).dictionaryValue
                
                if let numGames = j["totalItems"]?.int
                {
                    if numGames > 0, let dates = j["dates"]?.array
                    {
                        if dates.count > 0, let jsonGames = dates[0].dictionaryValue["games"]?.array
                        {
                            for jsonGame in jsonGames
                            {
                                let homeTeam = TeamManager.nhlTeams[jsonGame["teams"]["home"]["team"]["teamName"].stringValue]
                                let awayTeam = TeamManager.nhlTeams[jsonGame["teams"]["away"]["team"]["teamName"].stringValue]
                                
                                let gameDate = self.gmtFormatter.date(from: jsonGame["gameDate"].stringValue)
                                
                                if let homeTeam = homeTeam, let awayTeam = awayTeam, let gameDate = gameDate
                                {
                                    var gameFeeds = [Feed]()
                                    
                                    if let jsonMedia = jsonGame["content"]["media"]["epg"].array, jsonMedia.count > 0
                                    {
                                        for jsonFeed in jsonMedia[0]["items"].arrayValue
                                        {
                                            gameFeeds.append(Feed(feedType: jsonFeed["mediaFeedType"].stringValue,
                                                                  callLetters: jsonFeed["callLetters"].stringValue,
                                                                  feedName: jsonFeed["feedName"].stringValue,
                                                                  playbackID: jsonFeed["mediaPlaybackId"].intValue,
                                                                  league: League.NHL,
                                                                  gameDate: date))
                                        }
                                    }
                                    
                                    
                                    let gameState: String
                                    
                                    switch jsonGame["status"]["abstractGameState"].stringValue
                                    {
                                    case "Preview":
                                        let timeFormatter = DateFormatter()
                                        timeFormatter.dateFormat = "h:mm a"
                                        gameState = timeFormatter.string(from: gameDate)
                                        break
                                        
                                    case "Live":
                                        gameState = jsonGame["linescore"]["currentPeriodOrdinal"].stringValue + " – " + jsonGame["linescore"]["currentPeriodTimeRemaining"].stringValue
                                        break
                                        
                                    case "Final":
                                        gameState = "Final"
                                        break
                                        
                                    default:
                                        gameState = ""
                                        print("error")
                                        break
                                    }
                                    
                                    newGames.append(Game(homeTeam: homeTeam, awayTeam: awayTeam, startTime: gameDate, gameState: gameState, feeds: gameFeeds))
                                }
                            }
                            self.nhlGames[date] = newGames
                            DispatchQueue.main.async {
                                completion?(newGames)
                            }
                            
                        }
                    }
                    else
                    {
                        DispatchQueue.main.async {
                            errorCompletion?("There are no games today.")
                        }
                    }
                }
                else {
                    
                }
            }).resume()
            }
        }
    }
    
    private func getMLBGames(date: String, completion: (([Game]) -> ())?, errorCompletion: ((String) -> ())?)
    {
        let file = Bundle.main.path(forResource: "mlbschedule2018-04-05", ofType: "json")
        let data = try? Data(contentsOf: URL(fileURLWithPath: file!))
        
        let mlbStatsURL = String(format: self.mlbFormatURL, date)
        
        guard let url = URL(string: mlbStatsURL) else
        {
            errorCompletion?("Bad URL")
            return
        }
    
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        
        let session = URLSession.init(configuration: config)
        
        DispatchQueue.global(qos: .utility).async {
            session.dataTask(with: url) { (data, response, error) in
                
                
                
                
                var newGames: [Game] = []
                
                guard let mlbJSON = try? JSON(data: data!).dictionaryValue else { return } // data error
                
                guard let numGames = mlbJSON["totalItems"]?.int, numGames > 0 else { return } // no games
                
                guard let mlbGames = mlbJSON["dates"]?[0]["games"].array else { return } // json error
                
                for mlbGame in mlbGames
                {
                    let gameDate = self.gmtFormatter.date(from: mlbGame["gameDate"].stringValue)
                    
                    let homeTeam = TeamManager.mlbTeams[mlbGame["teams"]["home"]["team"]["teamName"].stringValue]
                    let awayTeam = TeamManager.mlbTeams[mlbGame["teams"]["away"]["team"]["teamName"].stringValue]
                    
                    
                    if let homeTeam = homeTeam, let awayTeam = awayTeam, let gameDate = gameDate
                    {
                        var gameFeeds = [Feed]()
                        
                        if let jsonMedia = mlbGame["content"]["media"]["epg"].array, jsonMedia.count > 0
                        {
                            for jsonFeed in jsonMedia[0]["items"].arrayValue
                            {
                                gameFeeds.append(Feed(feedType: jsonFeed["mediaFeedType"].stringValue,
                                                      callLetters: jsonFeed["callLetters"].stringValue,
                                                      feedName: jsonFeed["feedName"].stringValue,
                                                      playbackID: jsonFeed["id"].intValue,
                                                      league: League.MLB,
                                                      gameDate: date))
                            }
                        }
                        
                        let gameState: String
                        
                        switch mlbGame["status"]["detailedState"].stringValue
                        {
                        case "Preview":
                            let timeFormatter = DateFormatter()
                            timeFormatter.dateFormat = "h:mm a"
                            gameState = timeFormatter.string(from: gameDate)
                            
                        case "In Progress":
                            gameState = mlbGame["linescore"]["currentInningOrdinal"].stringValue + " – " + mlbGame["linescore"]["inningHalf"].stringValue
                            
                        case "Final":
                            gameState = "Final"
                            
                        default:
                            gameState = mlbGame["status"]["detailedState"].stringValue
                        }
                        
                        
                        
                        newGames.append(Game(homeTeam: homeTeam, awayTeam: awayTeam, startTime: gameDate, gameState: gameState, feeds: gameFeeds))
                    }
                    
                    
                }
                newGames.sort(by: { (game1, game2) -> Bool in
                    return game1.startTime >= game2.startTime
                })
                
                
                self.mlbGames[date] = newGames
                DispatchQueue.main.async {
                    completion?(newGames)
                }
                
                }.resume()
        }
    }
    
            
}
