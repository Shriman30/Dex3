//
//  FetchController.swift
//  Dex3
//
//  Created by Admin on 2023-07-24.
//

import Foundation

struct fetchController{
    enum NetworkError:Error{
        case badURL
        case badResponse
        case badData
    }

    // This base url returns a collection of data, one of which is the results.
    /*
     Goal: Get 3rd generation pokemons only -> 386 pokemons
     Note:
        - The base url returns a collection of information
        - We are interested in the results key
        - each results has a url which leads to the information required for our TempPokemon model
     */
    private let baseURL = URL(string:"https://pokeapi.co/api/v2/pokemon/")!
    

    func fetchAllPokemon() async throws ->[TempPokemon]{
        var allPokemon:[TempPokemon] = []
        
        var fetchComponents = URLComponents(url:baseURL, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name:"limit",value: "386")]
        
        guard let fetchURL = fetchComponents?.url else{
            throw NetworkError.badURL
        }
        let (data,response) = try await URLSession.shared.data(from:fetchURL)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw NetworkError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any], let pokdex = pokeDictionary["results"] as? [[String:String]] else{
            throw NetworkError.badData
        }
        
        // loop through each urls in pokedex and populate the list by accessing the url
        
        for pokemon in pokdex {
            if let url = pokemon["url"]{
                allPokemon.append(try await fetchPokemon(from:URL(string:url)!))
            }
        }
        
        return allPokemon
    }
    
    // function used to fetch a single pokemon and to return a tempPokemon
    private func fetchPokemon(from url:URL) async throws ->TempPokemon{
        let (data,response) = try await URLSession.shared.data(from:url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else{
            throw NetworkError.badResponse
        }
        
        // decode the data and convert it into a TempPokemon instance and assign it to the tempPokemon variable
        let tempPokemon = try JSONDecoder().decode(TempPokemon.self, from:data)
        print("Fetched \(tempPokemon.id): \(tempPokemon.name)")
        
        return tempPokemon
    }
}
