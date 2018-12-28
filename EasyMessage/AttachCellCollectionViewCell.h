//
//  AttachCellCollectionViewCell.h
//  
//
//  Created by PC Dreams on 18/12/2018.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AttachCellCollectionViewCell : UICollectionViewCell
@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *attachImage;
@property (weak, nonatomic) IBOutlet UIImageView *removeAttachment;

@end

NS_ASSUME_NONNULL_END
