//
//  ViewController.swift
//  ChatGPTRapper
//
//  Created by James Chen on 17/10/25.
//

import UIKit

  final class MainViewController: UIViewController {
      private var aiService: RapperChatService?
      
      private let promptField: UITextField = {
          let field = UITextField()
          field.placeholder = "Ask the rap mentor…"
          field.borderStyle = .roundedRect
          field.returnKeyType = .send
          return field
      }()

      private let sendButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Hit it!", for: .normal)
          return button
      }()

      private let responseView: UITextView = {
          let textView = UITextView()
          textView.isEditable = false
          textView.isSelectable = true
          textView.text = "Your rhymes will land here."
          textView.font = .preferredFont(forTextStyle: .body)
          textView.backgroundColor = .secondarySystemBackground
          textView.layer.cornerRadius = 12
          textView.layer.borderWidth = 1
          textView.layer.borderColor = UIColor.separator.cgColor
          textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
          return textView
      }()

      override func viewDidLoad() {
          super.viewDidLoad()
          view.backgroundColor = .systemBackground

          let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView])
          stack.axis = .vertical
          stack.spacing = 16
          stack.translatesAutoresizingMaskIntoConstraints = false

          title = "RapBot 🎤🤖"
          view.backgroundColor = .systemBackground
          
          setupNavigationBar()
          initialiseService()
          
          view.addSubview(stack)

          NSLayoutConstraint.activate([
              stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
              stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
              stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100),
              responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 220)
          ])

          sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
      }
      
      private func setupNavigationBar(){
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = .brown
          
          appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 30)]
          appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 30, weight: .semibold)]
          
            
          navigationController?.navigationBar.standardAppearance = appearance
          navigationController?.navigationBar.scrollEdgeAppearance = appearance
          navigationController?.navigationBar.compactAppearance = appearance
      }

      @objc
      private func sendTapped() {
          responseView.text = "Loading..."
          // TODO: Call your chat service and update responseView.text with the returned bars.
          guard let prompt = promptField.text, !prompt.isEmpty else {
              responseView.text = "Please enter a prompt."
              return
          }
          
          responseView.text = "Cooking some 🔥 hol' up!"
          sendButton.isEnabled = false
          
          Task{
              do{
                  guard let aiService = self.aiService else {
                      responseView.text = "The AI service isn't available. Check the setup."
                      return
                  }
                  
                  let response = try await aiService.respond(to: prompt)
                  self.responseView.text = response
              }catch{
                  self.responseView.text = "🔥 Whoops, an error dropped: \(error.localizedDescription)"
              }
              
              sendButton.isEnabled = true
          }
      }
      
      private func initialiseService(){
          do{
              guard let apiKey = ProcessInfo.processInfo.environment["OPEN_API_KEY"] else {
                  showAlert(title: "Configuration Error", message: "API Key is not set.")
                  disableInput()
                  return
              }
              
              self.aiService = try RapperChatService(apiKey: apiKey)
          }catch{
              showAlert(title: "Initalisation failed", message: error.localizedDescription)
              disableInput()
          }
      }
      
      private func showAlert(title: String, message: String) {
              let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
              alert.addAction(UIAlertAction(title: "OK", style: .default))
              present(alert, animated: true)
          }
          
          private func disableInput() {
              promptField.isEnabled = false
              sendButton.isEnabled = false
              promptField.placeholder = "Service unavailable"
          }
  }
