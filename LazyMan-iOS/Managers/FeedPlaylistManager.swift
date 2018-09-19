//
//  FeedPlaylistManager.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 8/17/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import Foundation


/*
func getFeedPlaylists(cdn: CDN, completion: @escaping ([FeedPlaylist]) -> (), error: @escaping (String) -> ())
{
    if let feedPlaylists = self.feedPlaylists, let lastCDN = lastCDN, lastCDN == cdn
    {
        completion(feedPlaylists)
    }
    else
    {
        var playlists = [FeedPlaylist]()
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            if let masterURL = self.getMasterURL(cdn: cdn)
            {
                // Checking if stream has expired
                if masterURL.absoluteString.contains("exp"),
                    let exp = try? masterURL.absoluteString.replace("(.*)exp=(\\d+)(.*)", replacement: "$2"),
                    let expTime = Double(exp),
                    Date().timeIntervalSince1970 > expTime + 1000
                {
                    DispatchQueue.main.async {
                        error("The stream has expired. Please report the game you are trying to play.")
                    }
                    return
                }
                
                playlists.append(FeedPlaylist(url: masterURL, quality: "Auto", bandwidth: nil, framerate: nil))
                
                let masterPlaylist = ManifestBuilder().parse(masterURL)
                
                for index in 0..<masterPlaylist.getPlaylistCount()
                {
                    if let mediaPlaylist = masterPlaylist.getPlaylist(index),
                        let mediaPath = mediaPlaylist.path,
                        let mediaURL = masterURL.URLByReplacingLastPathComponent(mediaPath)
                    {
                        
                        var framerate: Int?
                        
                        if let mpFramerate = mediaPlaylist.framerate
                        {
                            framerate = Int(mpFramerate.rounded())
                        }
                        
                        playlists.append(FeedPlaylist(url: mediaURL,
                                                      quality: mediaPlaylist.resolution ?? "Unknown",
                                                      bandwidth: mediaPlaylist.bandwidth,
                                                      framerate: framerate))
                        
                    }
                    
                }
                DispatchQueue.main.async {
                    playlists.sort(by: { (feed1, feed2) -> Bool in
                        
                        let f1b = feed1.getBandwidth() ?? Int.max
                        let f2b = feed2.getBandwidth() ?? Int.max
                        
                        return f1b > f2b
                    })
                    self.feedPlaylists = playlists
                    completion(playlists)
                }
            }
            else
            {
                DispatchQueue.main.async {
                    
                    if self.gameTime > Date()
                    {
                        error("No streams are avalible for this game yet. Check back later.")
                    }
                    else
                    {
                        error("Error getting game stream. The server may be down or the game may be currently unavailable.")
                    }
                }
            }
        }
    }
}

func getTitle() -> String
{
    if self.feedName != ""
    {
        return feedName
    }
    else
    {
        if self.callLetters != ""
        {
            return String(format: "%@ (%@)", self.feedType, callLetters)
        }
        else
        {
            return self.feedType
        }
    }
}

func getDetail() -> String
{
    return ""
}

// MARK: - Private

/**
 Gets the master URL for the stream.
 
 - parameter cdn: the CDN the stream should be attempted to be loaded from
 - returns: A URL of this Feed's master playlist, or nil if it cannot be loaded
 */
private func getMasterURL(cdn: CDN) -> URL?
{
    let masterURLSource = "http://nhl.freegamez.ga/getM3U8.php?league=\(self.league.rawValue)&date=\(self.gameDate)&id=\(self.playbackID)&cdn=\(cdn.rawValue)"
    
    if let contents = try? String(contentsOf: URL(string: masterURLSource)!)
    {
        return URL(string: contents)
    }
    else
    {
        return nil
    }
}
*/
