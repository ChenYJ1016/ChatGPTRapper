//
//  RapperChatService.swift
//  ChatGPTRapper
//
//  Created by James Chen on 17/10/25.
//

import Foundation
import OpenAI

class RapperChatService {
    private let openAI: OpenAI

    private let systemPrompt = """
    You are RockBot GPT, a legendary rockstar with a rebellious spirit. Answer with epic, poetic lyrics full of metaphors, and a touch of defiance. Keep it to a 4-line verse, and end with a "Rock on!".
    """


    enum RapperChatError: LocalizedError{
        case missingAPIKey
        case emptyInput
        case emptyResponse
        case invalidAPIKey
        case environmentVariableNotSet
        case noResponseContent
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Missing API key."
            case .emptyInput:
                return "Input text is empty."
            case .emptyResponse:
                return "OpenAI response is empty."
            case .invalidAPIKey:
                return "API Key provided is invalid or does not match"
            case .environmentVariableNotSet:
                return "environment variable not set"
            case.noResponseContent:
                return "The API call returned without any content. Please try again."
            }
        }
    }
    
    func respond(to text: String) async throws -> String {
            let query = ChatQuery(
                messages: [.system(.init(content: .textContent(systemPrompt))), .user(.init(content: .string(text)))], model: .gpt5)
            
            let results = try await openAI.chats(query: query)
            
        guard let responseContent = results.choices.first?.message.content else {
            throw RapperChatError.noResponseContent
        }
       
        return responseContent
    }
    
    init(apiKey: String? = nil) throws {
        guard let validKey = ProcessInfo.processInfo.environment["OPEN_API_KEY"] else {
                    throw RapperChatError.environmentVariableNotSet
                }
        
        guard let providedKey = apiKey else {
                    throw RapperChatError.missingAPIKey
                }

        guard providedKey == validKey else {
            throw RapperChatError.invalidAPIKey
        }

        self.openAI = OpenAI(apiToken: providedKey)
    }
}
