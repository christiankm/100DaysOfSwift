//
//  ViewController.swift
//  Project25
//
//  Created by Christian Mitteldorf on 24/07/2019.
//  Copyright © 2019 MobilePay. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController  {

    var images = [UIImage]()

    var peerId = MCPeerID(displayName: UIDevice.current.name)
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?

    private let serviceType = "hws-project25"

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Selfie Share"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))

        mcSession = MCSession(peer: peerId, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self
    }

    @objc func showConnectionPrompt() {
        let alertController = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        alertController.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alertController, animated: true)
    }

    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start()
    }

    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return }
        let mcBrowser = MCBrowserViewController(serviceType: serviceType, session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
    }
}

extension ViewController: UINavigationControllerDelegate {}

extension ViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        images.insert(image, at: 0)
        collectionView.reloadData()

        // Send image to peers
        guard let mcSession = mcSession, !mcSession.connectedPeers.isEmpty else { return }

        if let imageData = image.pngData() {
            do {
                try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
            } catch {
                let alertController = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default))
                present(alertController, animated: true)
            }
        }
    }
}

extension ViewController {

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)

        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }

        return cell
    }
}

extension ViewController: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)")
        case .connecting:
            print("Connecting: \(peerID.displayName)")
        case .notConnected:
            print("Not Connected: \(peerID.displayName)")
        @unknown default:
            print("Unknown state received: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            }
        }
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
}

extension ViewController: MCBrowserViewControllerDelegate {

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
}
