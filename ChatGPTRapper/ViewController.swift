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
          field.placeholder = "What's your anthem?"
          field.borderStyle = .roundedRect
          field.returnKeyType = .send
          return field
      }()

      private let sendButton: UIButton = {
          let button = UIButton(type: .system)
          button.setTitle("Rock it!", for: .normal)
          button.backgroundColor = UIColor.red
          button.tintColor = .white
          button.layer.cornerRadius = 8
          button.titleLabel?.font = .boldSystemFont(ofSize: 16)
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
          textView.layer.shadowColor = UIColor.black.cgColor
          textView.layer.shadowOffset = CGSize(width: 0, height: 2)
          textView.layer.shadowOpacity = 0.2
          textView.layer.shadowRadius = 4
          textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
          return textView
      }()

      override func viewDidLoad() {
          super.viewDidLoad()
          setupGradientBackground()

          let stack = UIStackView(arrangedSubviews: [promptField, sendButton, responseView])
          stack.axis = .vertical
          stack.spacing = 20
          stack.translatesAutoresizingMaskIntoConstraints = false

          title = "RockBot 🎸🤘"
          
          setupNavigationBar()
          initialiseService()
          
          view.addSubview(stack)

          NSLayoutConstraint.activate([
              stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
              stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
              stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
              responseView.heightAnchor.constraint(greaterThanOrEqualToConstant: 250)
          ])

          sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
      }
      
      private func setupGradientBackground() {
          let gradientLayer = CAGradientLayer()
          gradientLayer.frame = view.bounds
          gradientLayer.colors = [
              UIColor.orange.cgColor,
              UIColor.red.cgColor
          ]
          view.layer.insertSublayer(gradientLayer, at: 0)
      }
      
      override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
          if let gradientLayer = view.layer.sublayers?.first as? CAGradientLayer {
              gradientLayer.frame = view.bounds
          }
      }
      
      private func setupNavigationBar(){
          let appearance = UINavigationBarAppearance()
          appearance.configureWithOpaqueBackground()
          appearance.backgroundColor = UIColor.orange
          
          appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.boldSystemFont(ofSize: 32)]
          appearance.titleTextAttributes = [.foregroundColor: UIColor.white, .font: UIFont.systemFont(ofSize: 24, weight: .semibold)]
          
            
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