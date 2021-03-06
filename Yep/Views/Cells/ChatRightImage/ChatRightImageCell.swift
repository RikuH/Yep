//
//  ChatRightImageCell.swift
//  Yep
//
//  Created by NIX on 15/3/31.
//  Copyright (c) 2015年 Catch Inc. All rights reserved.
//

import UIKit

class ChatRightImageCell: ChatRightBaseCell {

    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var borderImageView: UIImageView!

    typealias MediaTapAction = () -> Void
    var mediaTapAction: MediaTapAction?

    func makeUI() {

        let fullWidth = UIScreen.mainScreen().bounds.width

        let halfAvatarSize = YepConfig.chatCellAvatarSize() / 2

        avatarImageView.center = CGPoint(x: fullWidth - halfAvatarSize - YepConfig.chatCellGapBetweenWallAndAvatar(), y: halfAvatarSize)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }

        messageImageView.tintColor = UIColor.rightBubbleTintColor()
        
        messageImageView.userInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: "tapMediaView")
        messageImageView.addGestureRecognizer(tap)

        prepareForMenuAction = { otherGesturesEnabled in
            tap.enabled = otherGesturesEnabled
        }
    }

    func tapMediaView() {
        mediaTapAction?()
    }

    var loadingProgress: Double = 0

    func loadingWithProgress(progress: Double, image: UIImage?) {

        if progress >= loadingProgress {

            if progress <= 1.0 {
                loadingProgress = progress
            }

            if let image = image {

                dispatch_async(dispatch_get_main_queue()) { [weak self] in

                    self?.messageImageView.image = image

                    UIView.animateWithDuration(YepConfig.ChatCell.imageAppearDuration, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                        self?.messageImageView.alpha = 1.0
                    }, completion: { (finished) -> Void in
                    })
                }
            }
        }
    }

    func configureWithMessage(message: Message, messageImagePreferredWidth: CGFloat, messageImagePreferredHeight: CGFloat, messageImagePreferredAspectRatio: CGFloat, mediaTapAction: MediaTapAction?, collectionView: UICollectionView, indexPath: NSIndexPath) {

        self.message = message
        self.user = message.fromFriend

        self.mediaTapAction = mediaTapAction

        UIView.performWithoutAnimation { [weak self] in
            self?.makeUI()
        }

        if let sender = message.fromFriend {
            let userAvatar = UserAvatar(userID: sender.userID, avatarStyle: nanoAvatarStyle)
            avatarImageView.navi_setAvatar(userAvatar, withFadeTransitionDuration: avatarFadeTransitionDuration)
        }

        loadingProgress = 0
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.messageImageView.alpha = 0.0
        }
    

        if let (imageWidth, imageHeight) = imageMetaOfMessage(message) {

            let aspectRatio = imageWidth / imageHeight

            let messageImagePreferredWidth = max(messageImagePreferredWidth, ceil(YepConfig.ChatCell.mediaMinHeight * aspectRatio))
            let messageImagePreferredHeight = max(messageImagePreferredHeight, ceil(YepConfig.ChatCell.mediaMinWidth / aspectRatio))

            if aspectRatio >= 1 {
                let width = messageImagePreferredWidth
                
                UIView.performWithoutAnimation { [weak self] in

                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.messageImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.messageImageView.frame))

                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }
                
                ImageCache.sharedInstance.imageOfMessage(message, withSize: CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / aspectRatio)), tailDirection: .Right, completion: { [weak self] progress, image in

                    dispatch_async(dispatch_get_main_queue()) {
                        if let _ = collectionView.cellForItemAtIndexPath(indexPath) {
                            self?.loadingWithProgress(progress, image: image)
                        }
                    }
                })

            } else {
                let width = messageImagePreferredHeight * aspectRatio
                
                UIView.performWithoutAnimation { [weak self] in

                    if let strongSelf = self {
                        strongSelf.messageImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                        strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.messageImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.messageImageView.frame))

                        strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                    }
                }

                ImageCache.sharedInstance.imageOfMessage(message, withSize: CGSize(width: messageImagePreferredHeight * aspectRatio, height: messageImagePreferredHeight), tailDirection: .Right, completion: { [weak self] progress, image in

                    dispatch_async(dispatch_get_main_queue()) {
                        if let _ = collectionView.cellForItemAtIndexPath(indexPath) {
                            self?.loadingWithProgress(progress, image: image)
                        }
                    }
                })
            }

        } else {
            let width = messageImagePreferredWidth
            
            UIView.performWithoutAnimation { [weak self] in

                if let strongSelf = self {
                    strongSelf.messageImageView.frame = CGRect(x: CGRectGetMinX(strongSelf.avatarImageView.frame) - YepConfig.ChatCell.gapBetweenAvatarImageViewAndBubble - width, y: 0, width: width, height: strongSelf.bounds.height)
                    strongSelf.dotImageView.center = CGPoint(x: CGRectGetMinX(strongSelf.messageImageView.frame) - YepConfig.ChatCell.gapBetweenDotImageViewAndBubble, y: CGRectGetMidY(strongSelf.messageImageView.frame))

                    strongSelf.borderImageView.frame = strongSelf.messageImageView.frame
                }
            }

            ImageCache.sharedInstance.imageOfMessage(message, withSize: CGSize(width: messageImagePreferredWidth, height: ceil(messageImagePreferredWidth / messageImagePreferredAspectRatio)), tailDirection: .Right, completion: { [weak self] progress, image in

                dispatch_async(dispatch_get_main_queue()) {
                    if let _ = collectionView.cellForItemAtIndexPath(indexPath) {
                        self?.loadingWithProgress(progress, image: image)
                    }
                }
            })
        }
    }
}


