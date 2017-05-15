//
//  TGFlowLayout.swift
//  TangramKit
//
//  Created by apple on 16/3/13.
//  Copyright © 2016年 youngsoft. All rights reserved.
//

import UIKit

/**
 *流式布局是一种里面的子视图按照添加的顺序依次排列，当遇到某种约束限制后会另起一排再重新排列的多行多列展示的布局视图。这里的约束限制主要有数量约束限制和内容尺寸约束限制两种，排列的方向又分为垂直和水平方向，因此流式布局一共有垂直数量约束流式布局、垂直内容约束流式布局、水平数量约束流式布局、水平内容约束流式布局。流式布局主要应用于那些有规律排列的场景，在某种程度上可以作为UICollectionView的替代品。
 1.垂直数量约束流式布局
 tg_orientation=.vert,tg_arrangedCount>0
 
 
 每排数量为3的垂直数量约束流式布局
         =>
 +------+---+-----+
 |  A   | B |  C  |
 +---+--+-+-+-----+
 | D |  E |   F   |  |
 +---+-+--+--+----+  v
 |  G  |  H  | I  |
 +-----+-----+----+
 
 2.垂直内容约束流式布局.
 tg_orientation = .vert,tg_arrangedCount = 0
 
 垂直内容约束流式布局
          =>
 +-----+-----------+
 |  A  |     B     |
 +-----+-----+-----+
 |  C  |  D  |  E  |  |
 +-----+-----+-----+  v
 |        F        |
 +-----------------+
 
 
 
 3.水平数量约束流式布局。
 tg_orientation = .horz,tg_arrangedCount > 0
 
 每排数量为3的水平数量约束流式布局
            =>
    +-----+----+-----+
    |  A  | D  |     |
    |     |----|  G  |
    |-----|    |     |
 |  |  B  | E  |-----|
 V  |-----|    |     |
    |     |----|  H  |
    |  C  |    |-----|
    |     | F  |  I  |
    +-----+----+-----+
 
 
 
 4.水平内容约束流式布局
 tg_orientation = .horz,arrangedCount = 0
 
 
 水平内容约束流式布局
         =>
    +-----+----+-----+
    |  A  | C  |     |
    |     |----|     |
    |-----|    |     |
 |  |     | D  |     |
 V  |     |    |  F  |
    |  B  |----|     |
    |     |    |     |
    |     | E  |     |
    +-----+----+-----+
 
 
 
 
 流式布局中排的概念是一个通用的称呼，对于垂直方向的流式布局来说一排就是一行，垂直流式布局每排依次从上到下排列，每排内的子视图则是由左往右依次排列；对于水平方向的流式布局来说一排就是一列，水平流式布局每排依次从左到右排列，每排内的子视图则是由上往下依次排列
 
 */
open class TGFlowLayout:TGBaseLayout,TGFlowLayoutViewSizeClass {
    
    /**
     *初始化一个流式布局并指定布局的方向和布局的数量,如果数量为0则表示内容约束流式布局
     */
    public convenience init(_ orientation:TGOrientation = .vert, arrangedCount:Int = 0) {
        self.init(frame:.zero, orientation:orientation, arrangedCount:arrangedCount)
    }
    
    
    public init(frame: CGRect, orientation:TGOrientation = .vert, arrangedCount:Int = 0) {
        
        super.init(frame:frame)
        let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
        lsc.tg_orientation = orientation
        lsc.tg_arrangedCount = arrangedCount
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    /**
     *流式布局的布局方向
     *如果是.vert则表示每排先从左到右，再从上到下的垂直布局方式，这个方式是默认方式。
     *如果是.horz则表示每排先从上到下，在从左到右的水平布局方式。
     */
    public var tg_orientation:TGOrientation {
        get {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_orientation
        }
        set {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_orientation != newValue)
            {
                lsc.tg_orientation = newValue
                setNeedsLayout()
            }
        }
    }
    
    /**
     *指定方向上的子视图的数量，默认是0表示为内容约束流式布局，当数量不为0时则是数量约束流式布局。当值为0时则表示当子视图在方向上的尺寸超过布局视图时则会新起一排。而如果数量不为0时则：
     如果方向为.vert，则表示从左到右的数量，当子视图从左往右满足这个数量后新的子视图将会新起一排
     如果方向为.horz，则表示从上到下的数量，当子视图从上往下满足这个数量后新的子视图将会新起一排
     */
    public var tg_arrangedCount:Int {   //get/set方法
        get {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_arrangedCount
        }
        set {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_arrangedCount != newValue)
            {
                lsc.tg_arrangedCount = newValue
                setNeedsLayout()
            }
        }
    }
    
    
    
    /**
     *为流式布局提供分页展示的能力,默认是0表不支持分页展示，当设置为非0时则要求必须是tg_arrangedCount的整数倍数，表示每页的子视图的数量。而tg_arrangedCount则表示每排的子视图的数量。当启用tg_pagedCount时要求将流式布局加入到UIScrollView或者其派生类中才能生效。只有数量约束流式布局才支持分页展示的功能，tg_pagedCount和tg_height.isWrap以及tg_width.isWrap配合使用能实现不同的分页展示能力:
     
     1.垂直数量约束流式布局的tg_height设置为.wrap时则以UIScrollView的尺寸作为一页展示的大小，因为指定了一页的子视图数量，以及指定了一排的子视图数量，因此默认也会自动计算出子视图的宽度和高度，而不需要单独指出高度和宽度(子视图的宽度你也可以自定义)，整体的分页滚动是从上到下滚动。(每页布局时从左到右再从上到下排列，新页往下滚动继续排列)：
     1  2  3
     4  5  6
     -------  ↓
     7  8  9
     10 11 12
     
     2.垂直数量约束流式布局的tg_width设置为.wrap时则以UIScrollView的尺寸作为一页展示的大小，因为指定了一页的子视图数量，以及指定了一排的子视图数量，因此默认也会自动计算出子视图的宽度和高度，而不需要单独指出高度和宽度(子视图的高度你也可以自定义)，整体的分页滚动是从左到右滚动。(每页布局时从左到右再从上到下排列，新页往右滚动继续排列)
     1  2  3 | 7  8  9
     4  5  6 | 10 11 12
     →
     1.水平数量约束流式布局的tg_width设置为.wrap时则以UIScrollView的尺寸作为一页展示的大小，因为指定了一页的子视图数量，以及指定了一排的子视图数量，因此默认也会自动计算出子视图的宽度和高度，而不需要单独指出高度和宽度(子视图的高度你也可以自定义)，整体的分页滚动是从左到右滚动。(每页布局时从上到下再从左到右排列，新页往右滚动继续排列)
     1  3  5 | 7  9   11
     2  4  6 | 8  10  12
     →
     
     2.水平数量约束流式布局的tg_height设置为.wrap时则以UIScrollView的尺寸作为一页展示的大小，因为指定了一页的子视图数量，以及指定了一排的子视图数量，因此默认也会自动计算出子视图的宽度和高度，而不需要单独指出高度和宽度(子视图的宽度你也可以自定义)，整体的分页滚动是从上到下滚动。(每页布局时从上到下再从左到右排列，新页往下滚动继续排列)
     
     1  3  5
     2  4  6
     --------- ↓
     7  9  11
     8  10 12
     
     */
    public var tg_pagedCount:Int {
        get {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_pagedCount
        }
        set {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_pagedCount != newValue)
            {
                lsc.tg_pagedCount = newValue
                setNeedsLayout()
            }
        }
    }

    
    
    
    
    /**
     *子视图自动排列,这个属性只有在内容填充约束流式布局下才有用,默认为false.当设置为YES时则根据子视图的内容自动填充，而不是根据加入的顺序来填充，以便保证不会出现多余空隙的情况。
     *请在将所有子视图添加完毕并且初始布局完成后再设置这个属性，否则如果预先设置这个属性则在后续添加子视图时非常耗性能。
     */
    public var tg_autoArrange:Bool
        {
        get
        {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_autoArrange
        }
        set
        {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_autoArrange != newValue)
            {
                lsc.tg_autoArrange = newValue
                setNeedsLayout()
            }
        }
    }
    
    
    /**
     *流式布局内所有子视图的整体停靠对齐位置设定。
     *TGGravity.vert.top,TGGravity.vert.center,TGGravity.vert.bottom 表示整体垂直居上，居中，居下
     *TGGravity.horz.left,TGGravity.horz.center,TGGravity.horz.right 表示整体水平居左，居中，居右
     *TGGravity.vert.between 表示在流式布局里面，每行之间的行间距都被拉伸，以便使里面的子视图垂直方向填充满整个布局视图。
     *TGGravity.horz.between 表示在流式布局里面，每列之间的列间距都被拉伸，以便使里面的子视图水平方向填充满整个布局视图。
     *TGGravity.vert.fill 在垂直流式布局里面表示布局会拉伸每行子视图的高度，以便使里面的子视图垂直方向填充满整个布局视图的高度；在水平数量流式布局里面表示每列的高度都相等并且填充满整个布局视图的高度；在水平内容约束布局里面表示布局会自动拉升每列的高度，以便垂直方向填充满布局视图的高度。
     *TGGravity.horz.fill 在水平流式布局里面表示布局会拉伸每行子视图的宽度，以便使里面的子视图水平方向填充满整个布局视图的宽度；在垂直数量流式布局里面表示每行的宽度都相等并且填充满整个布局视图的宽度；在垂直内容约束布局里面表示布局会自动拉升每行的宽度，以便水平方向填充满布局视图的宽度。
     */
    public var tg_gravity:TGGravity {
        get {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_gravity
        }
        set {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_gravity != newValue)
            {
                lsc.tg_gravity = newValue
                setNeedsLayout()
            }
        }
    }
    
    /**
     *设置流式布局中每排子视图的对齐方式。
     如果布局的方向是.vert则表示每排子视图的上中下对齐方式，这里的对齐基础是以每排中的最高的子视图为基准。这个属性只支持：
     TGGravity.vert.top     顶部对齐
     TGGravity.vert.center  垂直居中对齐
     TGGravity.vert.bottom  底部对齐
     TGGravity.vert.fill    两端对齐
     如果布局的方向是.horz则表示每排子视图的左中右对齐方式，这里的对齐基础是以每排中的最宽的子视图为基准。这个属性只支持：
     TGGravity.horz.left    左边对齐
     TGGravity.horz.center  水平居中对齐
     TGGravity.horz.right   右边对齐
     TGGravity.horz.fill    两端对齐
     */
    public var tg_arrangedGravity:TGGravity {
        get {
            return (self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass).tg_arrangedGravity
        }
        set {
            let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClass
            if (lsc.tg_arrangedGravity != newValue)
            {
                lsc.tg_arrangedGravity = newValue
                setNeedsLayout()
            }
        }
    }
    
    
    /**
     *在内容约束流式布局的一些应用场景中我们有时候希望某些子视图的宽度是固定的情况下，子视图的间距是浮动的而不是固定的，这样就可以尽可能的容纳更多的子视图。比如每个子视图的宽度是固定80，那么在小屏幕下每行只能放3个，而我们希望大屏幕每行能放4个或者5个子视图。 因此您可以通过如下方法来设置浮动间距，这个方法会根据您当前布局的orientation方向不同而意义不同：
     1.如果您的布局方向是.vert表示设置的是子视图的水平间距，其中的size指定的是子视图的宽度，minSpace指定的是最小的水平间距,maxSpace指定的是最大的水平间距，如果指定的subviewSize计算出的间距大于这个值则会调整subviewSize的宽度。
     2.如果您的布局方向是.horz表示设置的是子视图的垂直间距，其中的size指定的是子视图的高度，minSpace指定的是最小的垂直间距,maxSpace指定的是最大的垂直间距，如果指定的subviewSize计算出的间距大于这个值则会调整subviewSize的高度。
     3.如果您不想使用浮动间距则请将subviewSize设置为0就可以了。
     4.这个方法只在内容约束流式布局里面设置才有意义。
     */
    public func tg_setSubviews(size:CGFloat, minSpace:CGFloat, maxSpace:CGFloat = .greatestFiniteMagnitude, inSizeClass type:TGSizeClassType = .default)
    {
        let lsc = self.tg_fetchSizeClass(with: type) as! TGFlowLayoutViewSizeClassImpl
        lsc.tgSubviewSize = size
        lsc.tgMinSpace = minSpace
        lsc.tgMaxSpace = maxSpace
        
        self.setNeedsLayout()
    }

    
    
    
    override internal func tgCalcLayoutRect(_ size:CGSize, isEstimate:Bool, sbs:[UIView]!, type:TGSizeClassType) ->(selfSize:CGSize, hasSubLayout:Bool) {
        var (selfSize, hasSubLayout) = super.tgCalcLayoutRect(size, isEstimate: isEstimate, sbs:sbs, type: type)
        
        var sbs:[UIView]! = sbs
        if sbs == nil
        {
          sbs = self.tgGetLayoutSubviews()
        }
        
        let lsc = self.tgCurrentSizeClass as! TGFlowLayoutViewSizeClassImpl
        
        
        for sbv:UIView in sbs {
            
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            if !isEstimate {
                sbvtgFrame.frame = sbv.bounds
                
                self.tgCalcSizeFromSizeWrapSubview(sbv, sbvsc:sbvsc, sbvtgFrame: sbvtgFrame)
            }
            
            if let sbvl:TGBaseLayout = sbv as? TGBaseLayout
            {
                hasSubLayout = true
                
                let sbvtgWidthIsWrap = sbvsc.tgWidth?.isWrap ?? false
                let sbvtgHeightIsWrap = sbvsc.tgHeight?.isWrap ?? false
                
                
                if sbvtgWidthIsWrap
                {
                    if ((lsc.tg_orientation == .horz && (lsc.tg_arrangedGravity & TGGravity.vert.mask) == TGGravity.horz.fill) ||
                        (lsc.tg_orientation == .vert && ((lsc.tg_gravity & TGGravity.vert.mask) == TGGravity.horz.fill)))
                    {
                        sbv.tgWidth!._dimeVal = nil
                    }
                }
                
                if sbvtgHeightIsWrap
                {
                    if ((lsc.tg_orientation == .vert && (lsc.tg_arrangedGravity & TGGravity.horz.mask) == TGGravity.vert.fill) ||
                        (lsc.tg_orientation == .horz && ((lsc.tg_gravity & TGGravity.horz.mask) == TGGravity.vert.fill)))
                    {
                        sbv.tgHeight!._dimeVal = nil
                    }
                }
                
                
                
                if (isEstimate && (sbvtgWidthIsWrap || sbvtgHeightIsWrap))
                {
                    _ = sbvl.tg_sizeThatFits(sbvtgFrame.frame.size,inSizeClass:type)
                    if sbvtgFrame.multiple
                    {
                        sbvtgFrame.sizeClass = sbv.tgMatchBestSizeClass(type)  //因为estimateLayoutRect执行后会还原，所以这里要重新设置
                    }
                }
            }
        }
        
        if lsc.tg_orientation == .vert {
            if lsc.tg_arrangedCount == 0 {
                
                
                if (lsc.tg_autoArrange)
                {
                    //计算出每个子视图的宽度。
                    for sbv in sbs
                    {
                        let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
                        let leadingSpace = sbvsc.tgLeading?.margin ?? 0
                        let trailingSpace = sbvsc.tgTrailing?.margin ?? 0
                        let sbvtgFrame = sbv.tgFrame
                        var rect = sbvtgFrame.frame;
                        
                        if (sbvsc.tgWidth?.dimeNumVal != nil)
                        {
                            rect.size.width = sbvsc.tgWidth!.measure;
                        }
                        
                        
                        rect = tgSetSubviewRelativeSize(sbvsc.tgWidth, selfSize: selfSize, lsc:lsc, rect: rect)
                        
                        rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                        
                        //暂时把宽度存放sbvtgFrame.trailing上。因为浮动布局来说这个属性无用。
                        sbvtgFrame.trailing = leadingSpace + rect.size.width + trailingSpace;
                        if (sbvtgFrame.trailing > selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding)
                        {
                            sbvtgFrame.trailing = selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding;
                        }
                    }
                    
                    let tempSbs:NSMutableArray = NSMutableArray(array: sbs)
                    sbs = self.tgGetAutoArrangeSubviews(tempSbs, selfSize:selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding, margin: lsc.tg_hspace) as! [UIView]
                    
                }
                
                
                
                selfSize = self.tgLayoutSubviewsForVertContent(selfSize, sbs: sbs, isEstimate:isEstimate, lsc:lsc)
            }
            else {
                selfSize = self.tgLayoutSubviewsForVert(selfSize, sbs: sbs, isEstimate:isEstimate, lsc:lsc)
            }
        }
        else {
            if lsc.tg_arrangedCount == 0 {
                
                
                if (lsc.tg_autoArrange)
                {
                    //计算出每个子视图的宽度。
                    for sbv in sbs
                    {
                        let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
                        let sbvtgFrame = sbv.tgFrame

                        let topSpace = sbvsc.tgTop?.margin ?? 0
                        let bottomSpace = sbvsc.tgBottom?.margin ?? 0
                        var rect = sbvtgFrame.frame;
                        
                        if (sbvsc.tgWidth?.dimeNumVal != nil)
                        {
                            rect.size.width = sbvsc.tgWidth!.measure;
                        }
                        
                        if (sbvsc.tgHeight?.dimeNumVal != nil)
                        {
                            rect.size.height = sbvsc.tgHeight!.measure;
                        }
                        
                        
                        rect = tgSetSubviewRelativeSize(sbvsc.tgHeight, selfSize: selfSize, lsc:lsc, rect: rect)
                        
                        rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                        
                       
                        rect = tgSetSubviewRelativeSize(sbvsc.tgWidth, selfSize: selfSize, lsc:lsc, rect: rect)
                        
                        rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                        
                        //如果高度是浮动的则需要调整高度。
                        if let t = sbvsc.tgHeight, t.isFlexHeight
                        {
                            rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                            
                            rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                        }
                        
                        
                        //暂时把宽度存放sbvtgFrame.trailing上。因为浮动布局来说这个属性无用。
                        sbvtgFrame.trailing = topSpace + rect.size.height + bottomSpace;
                        if (sbvtgFrame.trailing > selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)
                        {
                            sbvtgFrame.trailing = selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding;
                        }
                    }
                    
                    let tempSbs:NSMutableArray = NSMutableArray(array: sbs)
                    sbs = self.tgGetAutoArrangeSubviews(tempSbs, selfSize:selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding, margin: lsc.tg_vspace) as! [UIView]
                }
                
                
                
                selfSize = self.tgLayoutSubviewsForHorzContent(selfSize, sbs: sbs, isEstimate:isEstimate, lsc:lsc)
            }
            else {
                selfSize = self.tgLayoutSubviewsForHorz(selfSize, sbs: sbs, isEstimate:isEstimate, lsc:lsc)
            }
        }
        
        tgAdjustLayoutSelfSize(selfSize: &selfSize, lsc: lsc)
        
        tgAdjustSubviewsRTLPos(sbs: sbs, selfWidth: selfSize.width)
        
        return (self.tgAdjustSizeWhenNoSubviews(size: selfSize, sbs: sbs, lsc:lsc),hasSubLayout)
    }
    
    
    internal override func tgCreateInstance() -> AnyObject
    {
        return TGFlowLayoutViewSizeClassImpl(view:self)
    }

}

extension TGFlowLayout
{
    fileprivate  func tgCalcSingleLineSize(_ sbs:NSArray, margin:CGFloat) ->CGFloat
    {
        var size:CGFloat = 0;
        
        for i in 0..<sbs.count
        {
            let sbv = sbs[i] as! UIView
            
            size += sbv.tgFrame.trailing;
            if (sbv != sbs.lastObject as! UIView)
            {
                size += margin
            }
        }
        
        return size;
    }
    
    
    fileprivate func tgGetAutoArrangeSubviews(_ sbs:NSMutableArray, selfSize:CGFloat, margin:CGFloat) ->NSArray
    {
        
        let retArray:NSMutableArray = NSMutableArray(capacity: sbs.count)
        
        let bestSingleLineArray:NSMutableArray = NSMutableArray(capacity: sbs.count / 2)
        
        while (sbs.count > 0)
        {
            
            self.tgGetAutoArrangeSingleLineSubviews(sbs,
                                                   index:0,
                                                   calcArray:NSArray(),
                                                   selfSize:selfSize,
                                                   margin:margin,
                                                   bestSingleLineArray:bestSingleLineArray)
            
            retArray.addObjects(from: bestSingleLineArray as [AnyObject])
            
            bestSingleLineArray.forEach({ (obj) -> () in
                
                sbs.remove(obj)
            })
            
            bestSingleLineArray.removeAllObjects()
        }
        
        return retArray;
    }
    
    fileprivate func tgGetAutoArrangeSingleLineSubviews(_ sbs:NSMutableArray,index:Int,calcArray:NSArray,selfSize:CGFloat,margin:CGFloat,bestSingleLineArray:NSMutableArray)
    {
        if (index >= sbs.count)
        {
            let s1 = self.tgCalcSingleLineSize(calcArray, margin:margin)
            let s2 = self.tgCalcSingleLineSize(bestSingleLineArray, margin:margin)
            if (fabs(selfSize - s1) < fabs(selfSize - s2) && _tgCGFloatLessOrEqual(s1, selfSize))
            {
                bestSingleLineArray.setArray(calcArray as [AnyObject])
            }
            
            return;
        }
        
        
        for  i in  index ..< sbs.count
        {
            
            
            let calcArray2 =  NSMutableArray(array: calcArray)
            calcArray2.add(sbs[i])
            
            let s1 = self.tgCalcSingleLineSize(calcArray2,margin:margin)
            if ( _tgCGFloatLessOrEqual(s1, selfSize))
            {
                let s2 = self.tgCalcSingleLineSize(bestSingleLineArray,margin:margin)
                if (fabs(selfSize - s1) < fabs(selfSize - s2))
                {
                    bestSingleLineArray.setArray(calcArray2 as [AnyObject])
                }
                
                if ( _tgCGFloatEqual(s1, selfSize))
                {
                    break;
                }
                
                self.tgGetAutoArrangeSingleLineSubviews(sbs,
                                                       index:i + 1,
                                                       calcArray:calcArray2,
                                                       selfSize:selfSize,
                                                       margin:margin,
                                                       bestSingleLineArray:bestSingleLineArray)
                
            }
            else
            {
                break;
            }
            
        }
        
    }
    
    
    //计算Vert下每行Gravity对其方式
    fileprivate func tgCalcVertLayoutSingleLineGravity(_ selfSize:CGSize, rowMaxHeight:CGFloat, rowMaxWidth:CGFloat, mg:TGGravity, amg:TGGravity, sbs:[UIView], startIndex:Int, count:Int, vertSpace:CGFloat, horzSpace:CGFloat, isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl) {
        var addXPos:CGFloat = 0
        var addXFill:CGFloat = 0
        
        let averageArrange = (mg == TGGravity.horz.fill)
        
        //处理 对其方式
        if !averageArrange || lsc.tg_arrangedCount == 0 {
            switch mg {
            case TGGravity.horz.center:
                addXPos = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowMaxWidth)/2
                break
            case TGGravity.horz.trailing:
                //不用考虑左边距，而原来的位置增加了左边距 因此不用考虑
                addXPos = selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowMaxWidth
                break
            case TGGravity.horz.between:
                //总宽减去最大的宽度，再除以数量表示每个应该扩展的空间，对最后一行无效
                if (startIndex != sbs.count || count == lsc.tg_arrangedCount) && count > 1 {
                    addXFill = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowMaxWidth)/(CGFloat(count) - 1)
                }
                break
            default:
                break
            }
            //处理内容拉伸的情况
            if lsc.tg_arrangedCount == 0 && averageArrange {
                if startIndex != sbs.count {
                    addXFill = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowMaxWidth)/CGFloat(count)
                }
            }
        }
        
        //调整 整行子控件的位置
        for j in startIndex - count ..< startIndex
        {
            let sbv:UIView = sbs[j]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            if !isEstimate && self.tg_intelligentBorderline != nil
            {
                if let sbvl = sbv as? TGBaseLayout {
                    
                    if !sbvl.tg_notUseIntelligentBorderline {
                        sbvl.tg_leadingBorderline = nil
                        sbvl.tg_topBorderline = nil
                        sbvl.tg_trailingBorderline = nil
                        sbvl.tg_bottomBorderline = nil
                        
                        //如果不是最后一行就画下面，
                        if (startIndex != sbs.count)
                        {
                            sbvl.tg_bottomBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果不是最后一列就画右边,
                        if (j < startIndex - 1)
                        {
                            sbvl.tg_trailingBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果最后一行的最后一个没有满列数时
                        if (j == sbs.count - 1 && lsc.tg_arrangedCount != count )
                        {
                            sbvl.tg_trailingBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果有垂直间距则不是第一行就画上
                        if (vertSpace != 0 && startIndex - count != 0)
                        {
                            sbvl.tg_topBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果有水平间距则不是第一列就画左
                        if (horzSpace != 0 && j != startIndex - count)
                        {
                            sbvl.tg_leadingBorderline = self.tg_intelligentBorderline;
                        }
                        
                        
                    }
                }
            }
            
            if (amg != TGGravity.none && amg != TGGravity.vert.top) || _tgCGFloatNotEqual(addXPos, 0)  || _tgCGFloatNotEqual(addXFill, 0)
            {
                sbvtgFrame.leading += addXPos
                
                if lsc.tg_arrangedCount == 0 && averageArrange {
                    //只拉伸宽度 不拉伸间距
                    sbvtgFrame.width += addXFill
                    
                    if j != startIndex - count
                    {
                        sbvtgFrame.leading += addXFill * CGFloat(j - (startIndex - count))
                    }
                }
                else {
                    //只拉伸间距
                    sbvtgFrame.leading += addXFill * CGFloat(j - (startIndex - count))
                }
                
                let sbvTopSpace = sbvsc.tgTop?.margin ?? 0
                let sbvBottomSpace = sbvsc.tgBottom?.margin ?? 0
                
                switch amg {
                case TGGravity.vert.center:
                    sbvtgFrame.top += (rowMaxHeight - sbvTopSpace - sbvBottomSpace - sbvtgFrame.height) / 2
                    break
                case TGGravity.vert.bottom:
                    sbvtgFrame.top += rowMaxHeight - sbvTopSpace - sbvBottomSpace - sbvtgFrame.height
                    break
                case TGGravity.vert.fill:
                    sbvtgFrame.height =  self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rowMaxHeight - sbvTopSpace - sbvBottomSpace, sbvSize: sbvtgFrame.frame.size, selfLayoutSize: selfSize)
                    break
                default:
                    break
                }
            }
        }
    }

    
    //计算Horz下每行Gravity对其方式
    fileprivate func tgCalcHorzLayoutSingleLineGravity(_ selfSize:CGSize, colMaxHeight:CGFloat, colMaxWidth:CGFloat, mg:TGGravity, amg:TGGravity, sbs:[UIView], startIndex:Int, count:Int, vertSpace:CGFloat, horzSpace:CGFloat,isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl) {
        var addYPos:CGFloat = 0
        var addYFill:CGFloat = 0
        let averageArrange = (mg == TGGravity.vert.fill)
        
        if !averageArrange || lsc.tg_arrangedCount == 0 {
            switch mg {
            case TGGravity.vert.center:
                addYPos = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - colMaxHeight)/2
                break
            case TGGravity.vert.bottom:
                addYPos = selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - colMaxHeight
                break
            case TGGravity.vert.between:
                //总高减去最大高度，再除以数量表示每个应该扩展的空气，最后一列无效
                if (startIndex != sbs.count || count == lsc.tg_arrangedCount) && count > 1 {
                    addYFill = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - colMaxHeight)/(CGFloat(count) - 1)
                }
                break
            default:
                break
            }
            
            //处理内容拉伸的情况
            if lsc.tg_arrangedCount == 0 && averageArrange {
                if startIndex != sbs.count {
                    addYFill = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - colMaxHeight)/CGFloat(count)
                }
            }
        }
        
        //调整位置
        for j in startIndex - count ..< startIndex {
            let sbv:UIView = sbs[j]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            if !isEstimate && self.tg_intelligentBorderline != nil {
                
                
                if let sbvl = sbv as? TGBaseLayout {
                    if !sbvl.tg_notUseIntelligentBorderline {
                        sbvl.tg_leadingBorderline = nil
                        sbvl.tg_topBorderline = nil
                        sbvl.tg_trailingBorderline = nil
                        sbvl.tg_bottomBorderline = nil
                        
                        //如果不是最后一行就画下面，
                        if (j < startIndex - 1)
                        {
                            sbvl.tg_bottomBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果不是最后一列就画右边,
                        if (startIndex != sbs.count )
                        {
                            sbvl.tg_trailingBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果最后一行的最后一个没有满列数时
                        if (j == sbs.count - 1 && lsc.tg_arrangedCount != count )
                        {
                            sbvl.tg_bottomBorderline = self.tg_intelligentBorderline;
                        }
                        
                        //如果有垂直间距则不是第一行就画上
                        if (vertSpace != 0 && j != startIndex - count)
                        {
                            sbvl.tg_topBorderline = self.tg_intelligentBorderline
                        }
                        
                        //如果有水平间距则不是第一列就画左
                        if (horzSpace != 0 && startIndex - count != 0  )
                        {
                            sbvl.tg_leadingBorderline = self.tg_intelligentBorderline;
                        }
                        
                    }
                }
            }
            
            if (amg != TGGravity.none && amg != TGGravity.horz.leading) || _tgCGFloatNotEqual(addYPos, 0) ||
               _tgCGFloatNotEqual(addYFill, 0) {
                sbvtgFrame.top += addYPos
                
                if lsc.tg_arrangedCount == 0 && averageArrange {
                    //只拉伸宽度不拉伸间距
                    sbvtgFrame.height += addYFill
                    
                    if j != startIndex - count {
                        sbvtgFrame.top += addYFill * CGFloat(j - (startIndex - count))
                    }
                }
                else {
                    //只拉伸间距
                    sbvtgFrame.top += addYFill * CGFloat(j - (startIndex - count))
                }
                
                let sbvLeadingSpace = sbvsc.tgLeading?.margin ?? 0
                let sbvTrailingSpace = sbvsc.tgTrailing?.margin ?? 0
                
                switch amg {
                case TGGravity.horz.center:
                    sbvtgFrame.leading += (colMaxWidth - sbvLeadingSpace  - sbvTrailingSpace - sbvtgFrame.width)/2
                    break
                case TGGravity.horz.trailing:
                    sbvtgFrame.leading += colMaxWidth - sbvLeadingSpace - sbvTrailingSpace - sbvtgFrame.width
                    break
                case TGGravity.horz.fill:
                    sbvtgFrame.width =  self.tgValidMeasure(sbv.tg_width, sbv: sbv, calcSize: colMaxWidth - sbvLeadingSpace - sbvTrailingSpace, sbvSize: sbvtgFrame.frame.size, selfLayoutSize: selfSize)
                    break
                default:
                    break
                }
                
            }
        }
    }
    
    
    fileprivate func tgCalcVertLayoutSingleLineWeight(selfSize:CGSize, totalFloatWidth:CGFloat, totalWeight:CGFloat,sbs:[UIView],startIndex:NSInteger, count:NSInteger)
    {
        for j in startIndex - count ..< startIndex {
            let sbv:UIView = sbs[j]
            
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            let sbvtgWidthIsFill = sbvsc.tgWidth?.isFill ?? false
            let isWidthWeight = sbvsc.tgWidth?.dimeWeightVal != nil || sbvtgWidthIsFill
            if isWidthWeight
            {
                var widthWeight:CGFloat = 1.0
                if sbvsc.tgWidth?.dimeWeightVal != nil
                {
                    widthWeight = sbvsc.tgWidth!.dimeWeightVal.rawValue/100
                }
                
                sbvtgFrame.width =  self.tgValidMeasure(sbvsc.tgWidth, sbv:sbv,calcSize:sbvsc.tgWidth!.measure(totalFloatWidth * widthWeight / totalWeight),sbvSize:sbvtgFrame.frame.size,selfLayoutSize:selfSize)
                sbvtgFrame.trailing = sbvtgFrame.leading + sbvtgFrame.width;
            }
        }
    }
    
    fileprivate func tgCalcHorzLayoutSingleLineWeight(selfSize:CGSize, totalFloatHeight:CGFloat, totalWeight:CGFloat,sbs:[UIView],startIndex:NSInteger, count:NSInteger)
    {
        for j in startIndex - count ..< startIndex {
            let sbv:UIView = sbs[j]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            let sbvtgHeightIsFill = sbvsc.tgHeight?.isFill ?? false
            let isHeightWeight = sbvsc.tgHeight?.dimeWeightVal != nil || sbvtgHeightIsFill

            
            if isHeightWeight
            {
                var heightWeight:CGFloat = 1.0
                if sbvsc.tgHeight?.dimeWeightVal != nil
                {
                    heightWeight = sbvsc.tgHeight!.dimeWeightVal.rawValue / 100
                }
                
                sbvtgFrame.height =  self.tgValidMeasure(sbvsc.tgHeight,sbv:sbv,calcSize:sbvsc.tgHeight!.measure(totalFloatHeight * heightWeight / totalWeight),sbvSize:sbvtgFrame.frame.size,selfLayoutSize:selfSize)
                sbvtgFrame.bottom = sbvtgFrame.top + sbvtgFrame.height;
                
                if (sbvsc.tgWidth?.dimeRelaVal != nil && sbvsc.tgWidth!.dimeRelaVal === sbvsc.tgHeight)
                {
                    sbvtgFrame.width = self.tgValidMeasure(sbvsc.tgWidth,sbv:sbv,calcSize:sbvsc.tgWidth!.measure(sbvtgFrame.height),sbvSize:sbvtgFrame.frame.size,selfLayoutSize:selfSize)
                }
                
            }
        }
    }
    
    //arrangedCount = 0；orientation = vert
    fileprivate func tgLayoutSubviewsForVert(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl)->CGSize {
        var selfSize = selfSize
        let arrangedCount:Int = lsc.tg_arrangedCount
        var xPos:CGFloat = lsc.tg_leadingPadding
        var yPos:CGFloat = lsc.tg_topPadding
        var rowMaxHeight:CGFloat = 0
        var rowMaxWidth:CGFloat = 0
        var maxWidth = lsc.tg_leadingPadding
        
        let mgvert:TGGravity = lsc.tg_gravity & TGGravity.horz.mask
        let mghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_gravity & TGGravity.vert.mask)
        let amgvert:TGGravity = lsc.tg_arrangedGravity & TGGravity.horz.mask
        
        let horzSpace = lsc.tg_hspace
        let vertSpace = lsc.tg_vspace
        
        
        //判断父滚动视图是否分页滚动
        var isPagingScroll = false
        if let scrolv = self.superview as? UIScrollView, scrolv.isPagingEnabled
        {
            isPagingScroll = true
        }
        
        var pagingItemHeight:CGFloat = 0
        var pagingItemWidth:CGFloat = 0
        var isVertPaging = false
        var isHorzPaging = false
        if lsc.tg_pagedCount > 0 && self.superview != nil
        {
            let rows = CGFloat(lsc.tg_pagedCount / arrangedCount)  //每页的行数。
            
            //对于垂直流式布局来说，要求要有明确的宽度。因此如果我们启用了分页又设置了宽度包裹时则我们的分页是从左到右的排列。否则分页是从上到下的排列。
            if let t = lsc.tgWidth, t.isWrap
            {
                isHorzPaging = true
                if isPagingScroll
                {
                    pagingItemWidth = (self.superview!.bounds.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - CGFloat(arrangedCount - 1) * horzSpace ) / CGFloat(arrangedCount)
                }
                else
                {
                    pagingItemWidth = (self.superview!.bounds.width - lsc.tg_leadingPadding - CGFloat(arrangedCount) * horzSpace ) / CGFloat(arrangedCount)
                }
                
                pagingItemHeight = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - (rows - 1) * vertSpace) / rows
            }
            else
            {
                isVertPaging = true
                pagingItemWidth = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - CGFloat(arrangedCount - 1) * horzSpace) / CGFloat(arrangedCount)
                //分页滚动时和非分页滚动时的高度计算是不一样的。
                if (isPagingScroll)
                {
                    pagingItemHeight = (self.superview!.bounds.height - lsc.tg_topPadding - lsc.tg_bottomPadding - (rows - 1) * vertSpace) / CGFloat(rows)
                }
                else
                {
                    pagingItemHeight = (self.superview!.bounds.height - lsc.tg_topPadding - rows * vertSpace) / rows
                }
                
            }
            
        }

        
        let averageArrange = (mghorz == TGGravity.horz.fill)
        
        var arrangedIndex:Int = 0
        var rowTotalWeight:CGFloat = 0
        var rowTotalFixedWidth:CGFloat = 0
        
        for i in 0..<sbs.count
        {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            let sbvtgWidthIsFill = sbvsc.tgWidth?.isFill ?? false
            let isWidthWeight = sbvsc.tgWidth?.dimeWeightVal != nil || sbvtgWidthIsFill
            
            if (arrangedIndex >= arrangedCount)
            {
                arrangedIndex = 0;
                
                if (rowTotalWeight != 0 && !averageArrange)
                {
                    self.tgCalcVertLayoutSingleLineWeight(selfSize:selfSize,totalFloatWidth:selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowTotalFixedWidth,totalWeight:rowTotalWeight,sbs:sbs,startIndex:i,count:arrangedCount)
                }
                
                rowTotalWeight = 0;
                rowTotalFixedWidth = 0;
                
            }
            
            let  leadingSpace = (sbvsc.tgLeading?.margin ?? 0)
            let  trailingSpace = (sbvsc.tgTrailing?.margin ?? 0)
            var  rect = sbvtgFrame.frame
            
            
            if isWidthWeight
            {
                if sbvtgWidthIsFill
                {
                    rowTotalWeight += 1.0
                }
                else
                {
                    rowTotalWeight += sbvsc.tgWidth!.dimeWeightVal.rawValue / 100
                }
            }
            else
            {
                if (pagingItemWidth != 0)
                {
                    rect.size.width = pagingItemWidth
                }
                
                if (sbvsc.tgWidth?.dimeNumVal != nil && !averageArrange)
                {
                    rect.size.width = sbvsc.tgWidth!.measure;
                }
                
                rect = tgSetSubviewRelativeSize(sbvsc.tgWidth, selfSize: selfSize, lsc:lsc,rect: rect)
                
                rect.size.width = self.tgValidMeasure(sbvsc.tgWidth,sbv:sbv,calcSize:rect.size.width,sbvSize:rect.size,selfLayoutSize:selfSize)
                
                rowTotalFixedWidth += rect.size.width;
            }
            
            rowTotalFixedWidth += leadingSpace + trailingSpace;
            
            if (arrangedIndex != (arrangedCount - 1))
            {
                rowTotalFixedWidth += horzSpace
            }
            
            sbvtgFrame.frame = rect;
            
            arrangedIndex += 1
            
        }
        
        //最后一行。
        if (rowTotalWeight != 0 && !averageArrange)
        {
            //如果最后一行没有填满则应该减去一个间距的值。
            if arrangedIndex < arrangedCount
            {
                rowTotalFixedWidth -= horzSpace
            }
            
            self.tgCalcVertLayoutSingleLineWeight(selfSize:selfSize,totalFloatWidth:selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowTotalFixedWidth,totalWeight:rowTotalWeight,sbs:sbs,startIndex:sbs.count, count:arrangedIndex)
        }
        
        
        var pageWidth:CGFloat = 0;  //页宽
        let averageWidth:CGFloat = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - (CGFloat(arrangedCount) - 1) * horzSpace) / CGFloat(arrangedCount)
        
        arrangedIndex = 0
        for i in 0..<sbs.count {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            //换行
            if arrangedIndex >= arrangedCount {
                arrangedIndex = 0
                yPos += rowMaxHeight
                yPos += vertSpace
                
                
                //分别处理水平分页和垂直分页。
                if (isHorzPaging)
                {
                    if (i % lsc.tg_pagedCount == 0)
                    {
                        pageWidth += self.superview!.bounds.width
                        
                        if (!isPagingScroll)
                        {
                            pageWidth -= lsc.tg_leadingPadding
                        }
                        
                        yPos = lsc.tg_topPadding;
                    }
                    
                }
                
                if (isVertPaging)
                {
                    //如果是分页滚动则要多添加垂直间距。
                    if (i % lsc.tg_pagedCount == 0)
                    {
                        
                        if (isPagingScroll)
                        {
                            yPos -= vertSpace
                            yPos += lsc.tg_bottomPadding
                            yPos += lsc.tg_topPadding
                        }
                    }
                }
                
                
                xPos = lsc.tg_leadingPadding + pageWidth

                
                //计算每行的gravity情况
                self .tgCalcVertLayoutSingleLineGravity(selfSize, rowMaxHeight: rowMaxHeight, rowMaxWidth: rowMaxWidth, mg: mghorz, amg: amgvert, sbs: sbs, startIndex: i, count: arrangedCount, vertSpace: vertSpace, horzSpace: horzSpace, isEstimate: isEstimate, lsc:lsc)
                
                rowMaxHeight = 0
                rowMaxWidth = 0
            }
            
            let topSpace = (sbvsc.tgTop?.margin ?? 0)
            let leadingSpace = (sbvsc.tgLeading?.margin ?? 0)
            let bottomSpace = (sbvsc.tgBottom?.margin ?? 0)
            let trailingSpace = (sbvsc.tgTrailing?.margin ?? 0)
            let sbvtgHeightIsFill = sbvsc.tgHeight?.isFill ?? false
            let isHeightWeight = sbvsc.tgHeight?.dimeWeightVal != nil || sbvtgHeightIsFill
            
            var rect = sbvtgFrame.frame
            
            if (pagingItemHeight != 0)
            {
                rect.size.height = pagingItemHeight
            }


            if sbvsc.tgHeight?.dimeNumVal != nil {
                rect.size.height = sbvsc.tgHeight!.measure
            }
            
            if averageArrange {
                rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: averageWidth - leadingSpace - trailingSpace, sbvSize: rect.size, selfLayoutSize:selfSize)
            }
            
            rect = tgSetSubviewRelativeSize(sbvsc.tgHeight, selfSize: selfSize, lsc:lsc, rect: rect)
            
            //如果高度是浮动的 则需要调整陶都
            let isFlexedHeight:Bool = sbvsc.tgHeight?.isFlexHeight ?? false
            if isFlexedHeight {
                
                rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
            }
            
            if isHeightWeight
            {
                var heightWeight:CGFloat = 1.0
                if sbvsc.tgHeight?.dimeWeightVal != nil
                {
                    heightWeight = sbvsc.tgHeight!.dimeWeightVal.rawValue/100
                }
                
                rect.size.height = sbvsc.tgHeight!.measure((selfSize.height - yPos - lsc.tg_bottomPadding)*heightWeight - topSpace - bottomSpace)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            rect.origin.x = (xPos + leadingSpace)
            rect.origin.y = (yPos + topSpace)
            xPos += (leadingSpace + rect.size.width + trailingSpace)
            
            if arrangedIndex != (arrangedCount - 1) {
                xPos += horzSpace
            }
            
            if rowMaxHeight < (topSpace + bottomSpace + rect.size.height) {
                rowMaxHeight = (topSpace + bottomSpace + rect.size.height)
            }
            
            if rowMaxWidth < (xPos - lsc.tg_leadingPadding) {
                rowMaxWidth = (xPos - lsc.tg_leadingPadding)
            }
            if maxWidth < xPos {
                maxWidth = xPos
            }
            
            sbvtgFrame.frame = rect
            arrangedIndex += 1
        }
        
        //最后一行 布局
        self .tgCalcVertLayoutSingleLineGravity(selfSize, rowMaxHeight: rowMaxHeight, rowMaxWidth: rowMaxWidth, mg: mghorz, amg: amgvert, sbs: sbs, startIndex: sbs.count, count: arrangedIndex,vertSpace: vertSpace, horzSpace: horzSpace, isEstimate: isEstimate, lsc:lsc)
        
        if let t = lsc.tgHeight, t.isWrap
        {
            selfSize.height = yPos + lsc.tg_bottomPadding + rowMaxHeight
            
            //只有在父视图为滚动视图，且开启了分页滚动时才会扩充具有包裹设置的布局视图的宽度。
            if (isVertPaging && isPagingScroll)
            {
                //算出页数来。如果包裹计算出来的宽度小于指定页数的宽度，因为要分页滚动所以这里会扩充布局的宽度。
                let totalPages:CGFloat = floor(CGFloat(sbs.count + lsc.tg_pagedCount - 1 ) / CGFloat(lsc.tg_pagedCount))
                if (selfSize.height < totalPages * self.superview!.bounds.height)
                {
                    selfSize.height = totalPages * self.superview!.bounds.height
                }
            }

            
        }
        else {
            var addYPos:CGFloat = 0
            var between:CGFloat = 0
            var fill:CGFloat = 0
            let arranges = floor(CGFloat(sbs.count + arrangedCount - 1) / CGFloat(arrangedCount))
            
            if mgvert == TGGravity.vert.center {
                addYPos = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos)/2
            }
            else if mgvert == TGGravity.vert.bottom {
                addYPos = selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos
            }
            else if (mgvert == TGGravity.vert.fill)
            {
                if (arranges > 0)
                {
                   fill = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos) / arranges
                }
            }
            else if (mgvert == TGGravity.vert.between)
            {
                
                if (arranges > 1)
                {
                   between = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos) / (arranges - 1)
                }
            }
            

            
            if addYPos != 0 || between != 0 || fill != 0
            {
                for i in 0..<sbs.count {
                    let sbv:UIView = sbs[i]
                    let sbvtgFrame = sbv.tgFrame
                    let line = i / arrangedCount
                    
                    sbvtgFrame.height += fill
                    sbvtgFrame.top += fill * CGFloat(line)
                    sbvtgFrame.top += addYPos
                    sbvtgFrame.top += between * CGFloat(line)
                }
            }
        }
        
        if let t = lsc.tgWidth, t.isWrap && !averageArrange
        {
            selfSize.width = maxWidth + lsc.tg_trailingPadding
            
            //只有在父视图为滚动视图，且开启了分页滚动时才会扩充具有包裹设置的布局视图的宽度。
            if (isHorzPaging && isPagingScroll)
            {
                //算出页数来。如果包裹计算出来的宽度小于指定页数的宽度，因为要分页滚动所以这里会扩充布局的宽度。
                let totalPages:CGFloat = floor(CGFloat(sbs.count + lsc.tg_pagedCount - 1 ) / CGFloat(lsc.tg_pagedCount))
                if (selfSize.width < totalPages * self.superview!.bounds.width)
                {
                    selfSize.width = totalPages * self.superview!.bounds.width
                }
            }

            
        }
        return selfSize
    }

    fileprivate func tgLayoutSubviewsForVertContent(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl)->CGSize {
        
        var selfSize = selfSize
        var xPos:CGFloat = lsc.tg_leadingPadding
        var yPos:CGFloat = lsc.tg_topPadding
        var rowMaxHeight:CGFloat = 0
        var rowMaxWidth:CGFloat = 0
        
        let mgvert:TGGravity = lsc.tg_gravity & TGGravity.horz.mask
        let mghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_gravity & TGGravity.vert.mask)
        let amgvert:TGGravity = lsc.tg_arrangedGravity & TGGravity.horz.mask
    
        let vertSpace = lsc.tg_vspace
        var horzSpace = lsc.tg_hspace
        var subviewSize = lsc.tgSubviewSize
        if (subviewSize != 0)
        {
            
            let minSpace = lsc.tgMinSpace
            let maxSpace = lsc.tgMaxSpace

            
            let rowCount =  floor((selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding  + minSpace) / (subviewSize + minSpace))
            if (rowCount > 1)
            {
                horzSpace = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - subviewSize * rowCount)/(rowCount - 1)
                
                if (horzSpace > maxSpace)
                {
                    horzSpace = maxSpace;
                    
                    subviewSize =  (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding -  horzSpace * (rowCount - 1)) / rowCount;
                    
                }
            }
        }

        var arrangeIndexSet = IndexSet()
        var arrangeIndex:Int = 0
        for i in 0..<sbs.count {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            let topSpace:CGFloat = (sbvsc.tgTop?.margin ?? 0)
            let leadingSpace:CGFloat = (sbvsc.tgLeading?.margin ?? 0)
            let bottomSpace:CGFloat = (sbvsc.tgBottom?.margin ?? 0)
            let trailingSpace:CGFloat = (sbvsc.tgTrailing?.margin ?? 0)
            
            let sbvtgWidthIsFill =  sbvsc.tgWidth?.isFill ?? false
            let sbvtgHeightIsFill = sbvsc.tgHeight?.isFill ?? false
            
            let isWidthWeight = sbvsc.tgWidth?.dimeWeightVal != nil || sbvtgWidthIsFill
            let isHeightWeight = sbvsc.tgHeight?.dimeWeightVal != nil || sbvtgHeightIsFill
            var rect:CGRect = sbvtgFrame.frame
            
            if subviewSize != 0
            {
                rect.size.width = subviewSize
            }
            
            if sbvsc.tgWidth?.dimeNumVal != nil {
                rect.size.width = sbvsc.tgWidth!.measure
            }
            if sbvsc.tgHeight?.dimeNumVal != nil {
                rect.size.height = sbvsc.tgHeight!.measure
            }
            
            rect = tgSetSubviewRelativeSize(sbv.tg_width, selfSize: selfSize, lsc:lsc, rect: rect)
            rect = tgSetSubviewRelativeSize(sbv.tg_height, selfSize: selfSize, lsc:lsc, rect: rect)

            if isHeightWeight
            {
                var heightWeight:CGFloat = 1.0
                if sbvsc.tgHeight?.dimeWeightVal != nil
                {
                    heightWeight = sbvsc.tgHeight!.dimeWeightVal.rawValue/100
                }
                
               rect.size.height = sbv.tg_height.measure((selfSize.height - yPos - lsc.tg_bottomPadding)*heightWeight - topSpace - bottomSpace)
            }
            
            if isWidthWeight
            {
                //如果过了，则表示当前的剩余空间为0了，所以就按新的一行来算。。
                var floatWidth = selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - rowMaxWidth;
                if  _tgCGFloatLessOrEqual(floatWidth, 0)
                {
                    floatWidth += rowMaxWidth
                    arrangeIndex = 0
                }
                
                if (arrangeIndex != 0)
                {
                    floatWidth -= horzSpace
                }
                
                var widthWeight:CGFloat = 1.0
                if sbvsc.tgWidth?.dimeWeightVal != nil
                {
                    widthWeight = sbvsc.tgWidth!.dimeWeightVal.rawValue/100
                }
                
                rect.size.width = (floatWidth + sbvsc.tgWidth!.addVal) * widthWeight - leadingSpace - trailingSpace;
            }
            
            
            rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.tgHeight?.dimeRelaVal != nil && sbvsc.tgHeight!.dimeRelaVal === sbvsc.tgWidth {
                rect.size.height = sbvsc.tgHeight!.measure(rect.size.width)
            }
            
            //如果高度是浮动则需要调整
            if let t = sbvsc.tgHeight, t.isFlexHeight {
                
                rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
            }
            
            rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            //计算xPos的值加上leadingSpace + rect.size.width + trailingSpace + lsc.tg_hspace 的值要小于整体的宽度。
            var place:CGFloat = xPos + leadingSpace + rect.size.width + trailingSpace
            if arrangeIndex != 0 {
                place += horzSpace
            }
            place += lsc.tg_trailingPadding
            
            //sbv所占据的宽度要超过了视图的整体宽度，因此需要换行。但是如果arrangedIndex为0的话表示这个控件的整行的宽度和布局视图保持一致。
            if place - selfSize.width > 0.0001
            {
                xPos = lsc.tg_leadingPadding
                yPos += vertSpace
                yPos += rowMaxHeight
                
                arrangeIndexSet.insert(i - arrangeIndex)
                //计算每行Gravity情况
                self .tgCalcVertLayoutSingleLineGravity(selfSize, rowMaxHeight: rowMaxHeight, rowMaxWidth: rowMaxWidth, mg: mghorz, amg: amgvert, sbs: sbs, startIndex: i, count: arrangeIndex, vertSpace: vertSpace, horzSpace: horzSpace, isEstimate: isEstimate, lsc:lsc)
                
                //计算单独的sbv的宽度是否大于整体的宽度。如果大于则缩小宽度。
                if leadingSpace + trailingSpace + rect.size.width > selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding
                {
                    rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - leadingSpace - trailingSpace, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                    if let t = sbvsc.tgHeight, t.isFlexHeight {
                        rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                        rect.size.height = self.tgValidMeasure(sbv.tg_height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                        
                    }
                }
                
                rowMaxHeight = 0
                rowMaxWidth = 0
                arrangeIndex = 0
            }
            
            if arrangeIndex != 0 {
                xPos += horzSpace
            }
            
            rect.origin.x = xPos + leadingSpace
            rect.origin.y = yPos + topSpace
            xPos += leadingSpace + rect.size.width + trailingSpace
            
            if rowMaxHeight < topSpace + bottomSpace + rect.size.height {
                rowMaxHeight = topSpace + bottomSpace + rect.size.height;
            }
            if rowMaxWidth < (xPos - lsc.tg_leadingPadding) {
                rowMaxWidth = (xPos - lsc.tg_leadingPadding);
            }
            
            sbvtgFrame.frame = rect;
            arrangeIndex += 1
        }
        
        //设置最后一行
        arrangeIndexSet.insert(sbs.count - arrangeIndex)
        self .tgCalcVertLayoutSingleLineGravity(selfSize, rowMaxHeight: rowMaxHeight, rowMaxWidth: rowMaxWidth, mg: mghorz, amg: amgvert, sbs: sbs, startIndex:sbs.count, count: arrangeIndex, vertSpace: vertSpace, horzSpace: horzSpace,isEstimate: isEstimate, lsc:lsc)
        
        if let t = lsc.tgHeight, t.isWrap {
            selfSize.height = yPos + lsc.tg_bottomPadding + rowMaxHeight;
        }
        else {
            var addYPos:CGFloat = 0
            var between:CGFloat = 0
            var fill:CGFloat = 0
            
            if mgvert == TGGravity.vert.center {
                addYPos = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos)/2
            }
            else if mgvert == TGGravity.vert.bottom {
                addYPos = selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos
            }
            else if mgvert == TGGravity.vert.fill {
            
                if arrangeIndexSet.count > 0
                {
                   fill = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos) / CGFloat(arrangeIndexSet.count)
                }
            }
            else if (mgvert == TGGravity.vert.between)
            {
                if arrangeIndexSet.count > 1
                {
                   between = (selfSize.height - lsc.tg_bottomPadding - rowMaxHeight - yPos) / CGFloat(arrangeIndexSet.count - 1)
                }
            }
                
            
            if addYPos != 0 || between != 0  || fill != 0
            {
                var line:CGFloat = 0
                var lastIndex:Int = 0
                
                for i in 0..<sbs.count {
                    let sbv:UIView = sbs[i]
                    let sbvtgFrame = sbv.tgFrame
                    sbvtgFrame.top += addYPos
                    
                    let index = arrangeIndexSet.integerLessThanOrEqualTo(i)
                    if lastIndex != index
                    {
                        lastIndex = index!
                        line += 1
                    }
                    
                    sbvtgFrame.height += fill
                    sbvtgFrame.top += fill * line
                    sbvtgFrame.top += between * line
                    
                }
            }
        }
        
        return selfSize
    }
    
    fileprivate func tgLayoutSubviewsForHorz(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl)->CGSize {
        
        let arrangedCount:Int = lsc.tg_arrangedCount
        var xPos:CGFloat = lsc.tg_leadingPadding
        var yPos:CGFloat = lsc.tg_topPadding
        var colMaxWidth:CGFloat = 0
        var colMaxHeight:CGFloat = 0
        var maxHeight:CGFloat = lsc.tg_topPadding
        var selfSize = selfSize
        
        let mgvert:TGGravity = lsc.tg_gravity & TGGravity.horz.mask
        let mghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_gravity & TGGravity.vert.mask)
        let amghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_arrangedGravity & TGGravity.vert.mask)

        let vertSpace = lsc.tg_vspace
        let horzSpace = lsc.tg_hspace
        
        
        //判断父滚动视图是否分页滚动
        var isPagingScroll = false
        if let scrolv = self.superview as? UIScrollView, scrolv.isPagingEnabled
        {
            isPagingScroll = true
        }
        
        var pagingItemHeight:CGFloat = 0
        var pagingItemWidth:CGFloat = 0
        var isVertPaging = false
        var isHorzPaging = false
        if lsc.tg_pagedCount > 0 && self.superview != nil
        {
            let cols = CGFloat(lsc.tg_pagedCount / arrangedCount)  //每页的列数。
            
            //对于水平流式布局来说，要求要有明确的高度。因此如果我们启用了分页又设置了高度包裹时则我们的分页是从上到下的排列。否则分页是从左到右的排列。
            if let t = lsc.tgHeight, t.isWrap
            {
                isVertPaging = true
                if isPagingScroll
                {
                    pagingItemHeight = (self.superview!.bounds.height - lsc.tg_topPadding - lsc.tg_bottomPadding - CGFloat(arrangedCount - 1) * vertSpace ) / CGFloat(arrangedCount)
                }
                else
                {
                    pagingItemHeight = (self.superview!.bounds.height - lsc.tg_topPadding - CGFloat(arrangedCount) * vertSpace ) / CGFloat(arrangedCount)
                }
                
                pagingItemWidth = (selfSize.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - (cols - 1) * horzSpace) / cols
            }
            else
            {
                isHorzPaging = true
                pagingItemHeight = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - CGFloat(arrangedCount - 1) * vertSpace) / CGFloat(arrangedCount)
                //分页滚动时和非分页滚动时的高度计算是不一样的。
                if (isPagingScroll)
                {
                    pagingItemWidth = (self.superview!.bounds.width - lsc.tg_leadingPadding - lsc.tg_trailingPadding - (cols - 1) * horzSpace) / cols
                }
                else
                {
                    pagingItemWidth = (self.superview!.bounds.width - lsc.tg_leadingPadding - cols * horzSpace) / cols
                }
                
            }
            
        }

        
        let averageArrange = (mgvert == TGGravity.vert.fill)
        
        var arrangedIndex:Int = 0
        var rowTotalWeight:CGFloat = 0
        var rowTotalFixedHeight:CGFloat = 0
        for i in 0..<sbs.count
        {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            let sbvtgHeightIsFill = sbvsc.tgHeight?.isFill ?? false
            let isHeightWeight = sbvsc.tgHeight?.dimeWeightVal != nil || sbvtgHeightIsFill

            
            if (arrangedIndex >= arrangedCount)
            {
                arrangedIndex = 0;
                
                if (rowTotalWeight != 0 && !averageArrange)
                {
                    self.tgCalcHorzLayoutSingleLineWeight(selfSize:selfSize,totalFloatHeight:selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - rowTotalFixedHeight,totalWeight:rowTotalWeight,sbs:sbs,startIndex:i,count:arrangedCount)
                }
                
                rowTotalWeight = 0;
                rowTotalFixedHeight = 0;
                
            }
            
            let  topSpace = (sbvsc.tgTop?.margin ?? 0)
            let  bottomSpace = (sbvsc.tgBottom?.margin ?? 0)
            var  rect = sbvtgFrame.frame;
            
            if (pagingItemWidth != 0)
            {
                rect.size.width = pagingItemWidth
            }
            
            if (sbvsc.tgWidth?.dimeNumVal != nil)
            {
                rect.size.width = sbvsc.tgWidth!.measure
            }
            
            
            rect = tgSetSubviewRelativeSize(sbvsc.tgWidth, selfSize: selfSize, lsc:lsc, rect: rect)
            
            rect.size.width = self.tgValidMeasure(sbvsc.tgWidth,sbv:sbv,calcSize:rect.size.width,sbvSize:rect.size,selfLayoutSize:selfSize)
            
            
            if isHeightWeight
            {
                if sbvtgHeightIsFill
                {
                    rowTotalWeight += 1.0
                }
                else
                {
                  rowTotalWeight += sbvsc.tgHeight!.dimeWeightVal.rawValue/100
                }
            }
            else
            {
                if (pagingItemHeight != 0)
                {
                    rect.size.height = pagingItemHeight
                }

            
                if (sbvsc.tgHeight?.dimeNumVal != nil && !averageArrange)
                {
                    rect.size.height = sbvsc.tgHeight!.measure;
                }
                
                
                rect = tgSetSubviewRelativeSize(sbvsc.tgHeight, selfSize: selfSize, lsc:lsc, rect: rect)
                
                
                //如果高度是浮动的则需要调整高度。
                let  isFlexedHeight = (sbvsc.tgHeight?.isFlexHeight ?? false)
                if (isFlexedHeight)
                {
                    rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                }
                
                rect.size.height = self.tgValidMeasure(sbvsc.tgHeight,sbv:sbv,calcSize:rect.size.height,sbvSize:rect.size,selfLayoutSize:selfSize)
                
                if (sbvsc.tgWidth?.dimeRelaVal != nil && sbvsc.tgWidth!.dimeRelaVal === sbvsc.tgHeight)
                {
                    rect.size.width = self.tgValidMeasure(sbvsc.tgWidth,sbv:sbv,calcSize:sbvsc.tgWidth!.measure(rect.size.height),sbvSize:rect.size,selfLayoutSize:selfSize)
                }
                
                rowTotalFixedHeight += rect.size.height;
            }
            
            rowTotalFixedHeight += topSpace + bottomSpace
            
            
            if (arrangedIndex != (arrangedCount - 1))
            {
                rowTotalFixedHeight += vertSpace
            }
            
            
            sbvtgFrame.frame = rect;
            
            arrangedIndex += 1
            
        }
        
        //最后一行。
        if (rowTotalWeight != 0 && !averageArrange)
        {
            if arrangedIndex < arrangedCount
            {
                rowTotalFixedHeight -= vertSpace
            }
            
            self.tgCalcHorzLayoutSingleLineWeight(selfSize:selfSize,totalFloatHeight:selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - rowTotalFixedHeight,totalWeight:rowTotalWeight,sbs:sbs,startIndex:sbs.count,count:arrangedIndex)
        }
        
        
        var pageHeight:CGFloat = 0
        let averageHeight:CGFloat = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - (CGFloat(arrangedCount) - 1) * vertSpace) / CGFloat(arrangedCount)
        
        arrangedIndex = 0
        for i in 0..<sbs.count {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            
            if arrangedIndex >= arrangedCount {
                arrangedIndex = 0
                xPos += colMaxWidth
                xPos += horzSpace

                
                //分别处理水平分页和垂直分页。
                if (isVertPaging)
                {
                    if (i % lsc.tg_pagedCount == 0)
                    {
                        pageHeight += self.superview!.bounds.height
                        
                        if (!isPagingScroll)
                        {
                            pageHeight -= lsc.tg_topPadding
                        }
                        
                        xPos = lsc.tg_leadingPadding;
                    }
                    
                }
                
                if (isHorzPaging)
                {
                    //如果是分页滚动则要多添加垂直间距。
                    if (i % lsc.tg_pagedCount == 0)
                    {
                        
                        if (isPagingScroll)
                        {
                            xPos -= horzSpace
                            xPos += lsc.tg_trailingPadding
                            xPos += lsc.tg_leadingPadding
                        }
                    }
                }
                
                
                yPos = lsc.tg_topPadding + pageHeight;

                
                
                
                //计算每行Gravity情况
                self.tgCalcHorzLayoutSingleLineGravity(selfSize, colMaxHeight: colMaxHeight, colMaxWidth: colMaxWidth, mg: mgvert, amg: amghorz, sbs: sbs, startIndex: i, count: arrangedCount, vertSpace: vertSpace, horzSpace: horzSpace, isEstimate: isEstimate, lsc:lsc)
                
                colMaxWidth = 0
                colMaxHeight = 0
            }
            
            let topSpace:CGFloat = (sbvsc.tgTop?.margin ?? 0)
            let leadingSpace:CGFloat = (sbvsc.tgLeading?.margin ?? 0)
            let bottomSpace:CGFloat = (sbvsc.tgBottom?.margin ?? 0)
            let trailingSpace:CGFloat = (sbvsc.tgTrailing?.margin ?? 0)
            let sbvtgWidthIsFill = sbvsc.tgWidth?.isFill ?? false
            let isWidthWeight = sbvsc.tgWidth?.dimeWeightVal != nil || sbvtgWidthIsFill

            var rect:CGRect = sbvtgFrame.frame
            
            if averageArrange {
                rect.size.height = (averageHeight - topSpace - bottomSpace)
                
                if (sbvsc.tgWidth?.dimeRelaVal != nil && sbvsc.tgWidth!.dimeRelaVal === sbvsc.tgHeight) {
                    rect.size.width = sbvsc.tgWidth!.measure(rect.size.height)
                    rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
                    
                }
            }
            
            if isWidthWeight
            {
                var widthWeight:CGFloat = 1.0
                if sbvsc.tgWidth?.dimeWeightVal != nil
                {
                    widthWeight = sbvsc.tgWidth!.dimeWeightVal.rawValue/100
                }
                
                rect.size.width = sbvsc.tgWidth!.measure((selfSize.width - xPos - lsc.tg_trailingPadding)*widthWeight - leadingSpace - trailingSpace)
                rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            }

            
            rect.origin.y = yPos + topSpace
            rect.origin.x = xPos + leadingSpace
            yPos += topSpace + rect.size.height + bottomSpace
            
            if arrangedIndex != (arrangedCount - 1) {
                yPos += vertSpace
            }
            
            if colMaxWidth < (leadingSpace + trailingSpace + rect.size.width) {
                colMaxWidth = leadingSpace + trailingSpace + rect.size.width
            }
            if colMaxHeight < (yPos - lsc.tg_topPadding) {
                colMaxHeight = yPos - lsc.tg_topPadding
            }
            if maxHeight < yPos {
                maxHeight = yPos
            }
            
            sbvtgFrame.frame = rect
            
            arrangedIndex += 1
        }
        
        //最后一列
        self .tgCalcHorzLayoutSingleLineGravity(selfSize, colMaxHeight: colMaxHeight, colMaxWidth: colMaxWidth, mg: mgvert, amg: amghorz, sbs: sbs, startIndex: sbs.count, count: arrangedIndex, vertSpace: vertSpace, horzSpace: horzSpace,isEstimate: isEstimate, lsc:lsc)
        
        if let t = lsc.tgHeight, t.isWrap  && !averageArrange
        {
            selfSize.height = maxHeight + lsc.tg_bottomPadding
            
            //只有在父视图为滚动视图，且开启了分页滚动时才会扩充具有包裹设置的布局视图的宽度。
            if (isVertPaging && isPagingScroll)
            {
                //算出页数来。如果包裹计算出来的宽度小于指定页数的宽度，因为要分页滚动所以这里会扩充布局的宽度。
                let totalPages:CGFloat = floor(CGFloat(sbs.count + lsc.tg_pagedCount - 1 ) / CGFloat(lsc.tg_pagedCount))
                if (selfSize.height < totalPages * self.superview!.bounds.height)
                {
                    selfSize.height = totalPages * self.superview!.bounds.height
                }
            }

        }
        
        if let t = lsc.tgWidth, t.isWrap
        {
            selfSize.width = xPos + lsc.tg_trailingPadding + colMaxWidth
            
            //只有在父视图为滚动视图，且开启了分页滚动时才会扩充具有包裹设置的布局视图的宽度。
            if (isHorzPaging && isPagingScroll)
            {
                //算出页数来。如果包裹计算出来的宽度小于指定页数的宽度，因为要分页滚动所以这里会扩充布局的宽度。
                let totalPages:CGFloat = floor(CGFloat(sbs.count + lsc.tg_pagedCount - 1 ) / CGFloat(lsc.tg_pagedCount))
                if (selfSize.width < totalPages * self.superview!.bounds.width)
                {
                    selfSize.width = totalPages * self.superview!.bounds.width
                }
            }

            
        }
        else {
            var addXPos:CGFloat = 0
            var between:CGFloat = 0
            var fill:CGFloat = 0
            let arranges = floor(CGFloat(sbs.count + arrangedCount - 1) / CGFloat(arrangedCount))

            
            if mghorz == TGGravity.horz.center {
                addXPos = (selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos) / 2
            }
            else if mghorz == TGGravity.horz.trailing {
                addXPos = selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos
            }
            else if (mghorz == TGGravity.horz.fill)
            {
                if (arranges > 0)
                {
                    fill = (selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos) / arranges
                }
            }
            else if (mghorz == TGGravity.horz.between)
            {
                if (arranges > 1)
                {
                   between = (selfSize.width - lsc.tg_leadingPadding - colMaxWidth - xPos) / (arranges - 1)
                }
            }

            
            
            if addXPos != 0 || between != 0 || fill != 0 {
                for i:Int in 0..<sbs.count {
                    let sbv:UIView = sbs[i]
                    let sbvtgFrame = sbv.tgFrame
                    
                    let line = i / arrangedCount
                    
                    sbvtgFrame.width += fill
                    sbvtgFrame.leading += fill * CGFloat(line)
                    sbvtgFrame.leading += addXPos
                    sbvtgFrame.leading += between * CGFloat(line)
                }
            }
        }
        return selfSize
    }

    fileprivate func tgLayoutSubviewsForHorzContent(_ selfSize:CGSize, sbs:[UIView], isEstimate:Bool, lsc:TGFlowLayoutViewSizeClassImpl)->CGSize {
        var xPos:CGFloat = lsc.tg_leadingPadding
        var yPos:CGFloat = lsc.tg_topPadding
        var colMaxWidth:CGFloat = 0
        var colMaxHeight:CGFloat = 0
        
        var selfSize = selfSize
        let mgvert:TGGravity = lsc.tg_gravity & TGGravity.horz.mask
        let mghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_gravity & TGGravity.vert.mask)
        let amghorz:TGGravity = self.tgConvertLeftRightGravityToLeadingTrailing(lsc.tg_arrangedGravity & TGGravity.vert.mask)

        
        //支持浮动垂直间距。
        let horzSpace = lsc.tg_hspace
        var vertSpace = lsc.tg_vspace
        var subviewSize = lsc.tgSubviewSize;
        if (subviewSize != 0)
        {
            
            let minSpace = lsc.tgMinSpace
            let maxSpace = lsc.tgMaxSpace

            let rowCount =  floor((selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding  + minSpace) / (subviewSize + minSpace))
            if (rowCount > 1)
            {
                vertSpace = (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - subviewSize * rowCount)/(rowCount - 1)
                
                if (vertSpace > maxSpace)
                {
                    vertSpace = maxSpace
                    
                    subviewSize =  (selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding -  vertSpace * (rowCount - 1)) / rowCount
                    
                }

            }
        }
        

        var arrangeIndexSet = IndexSet()
        var arrangedIndex:Int = 0
        for i in 0..<sbs.count {
            let sbv:UIView = sbs[i]
            let sbvsc = sbv.tgCurrentSizeClass as! TGViewSizeClassImpl
            let sbvtgFrame = sbv.tgFrame
            
            let topSpace:CGFloat = (sbvsc.tgTop?.margin ?? 0)
            let leadingSpace:CGFloat = (sbvsc.tgLeading?.margin ?? 0)
            let bottomSpace:CGFloat = (sbvsc.tgBottom?.margin ?? 0)
            let trailingSpace:CGFloat = (sbvsc.tgTrailing?.margin ?? 0)
            let sbvtgWidthIsFill = sbvsc.tgWidth?.isFill ?? false
            let sbvtgHeightIsFill = sbvsc.tgHeight?.isFill ?? false
            let isWidthWeight = sbvsc.tgWidth?.dimeWeightVal != nil || sbvtgWidthIsFill
            let isHeightWeight = sbvsc.tgHeight?.dimeWeightVal != nil || sbvtgHeightIsFill
            var rect:CGRect = sbvtgFrame.frame
            
            
            if sbvsc.tgWidth?.dimeNumVal != nil {
                rect.size.width = sbvsc.tgWidth!.measure
            }
            
            if sbvsc.tgHeight?.dimeNumVal != nil {
                rect.size.height = sbvsc.tgHeight!.measure
            }
            
            rect = tgSetSubviewRelativeSize(sbv.tg_height, selfSize: selfSize, lsc:lsc, rect: rect)
            
            if subviewSize != 0
            {
                rect.size.height = subviewSize
            }
            
            rect = tgSetSubviewRelativeSize(sbvsc.tgWidth, selfSize: selfSize, lsc:lsc, rect: rect)
            
            if isHeightWeight
            {
                //如果过了，则表示当前的剩余空间为0了，所以就按新的一行来算。。
                var floatHeight = selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - colMaxHeight;
                if (_tgCGFloatLessOrEqual(floatHeight, 0))
                {
                    floatHeight += colMaxHeight;
                    arrangedIndex = 0;
                }
                
                if (arrangedIndex != 0)
                {
                    floatHeight -= vertSpace
                }
                
                var heightWeight:CGFloat = 1.0
                if sbvsc.tgHeight?.dimeWeightVal != nil
                {
                    heightWeight = sbvsc.tgHeight!.dimeWeightVal.rawValue/100
                }
                
                rect.size.height = (floatHeight + sbvsc.tgHeight!.addVal) * heightWeight - topSpace - bottomSpace;
                
            }
            
            
            
            rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            if sbvsc.tgWidth?.dimeRelaVal != nil && sbvsc.tgWidth!.dimeRelaVal === sbvsc.tgHeight {
                rect.size.width = sbvsc.tgWidth!.measure(rect.size.height)
            }
            
            
            if isWidthWeight
            {
                var widthWeight:CGFloat = 1.0
                if sbvsc.tgWidth!.dimeWeightVal != nil
                {
                    widthWeight = sbvsc.tgWidth!.dimeWeightVal.rawValue / 100
                }
                
                rect.size.width = sbvsc.tgWidth!.measure((selfSize.width - xPos - lsc.tg_trailingPadding)*widthWeight - leadingSpace - trailingSpace)
            }

            
            rect.size.width = self.tgValidMeasure(sbvsc.tgWidth, sbv: sbv, calcSize: rect.size.width, sbvSize: rect.size, selfLayoutSize: selfSize)
            
            
            //如果高度是浮动则调整
            if let t = sbvsc.tgHeight, t.isFlexHeight {
                
                rect.size.height = self.tgCalcHeightFromHeightWrapView(sbv, sbvsc:sbvsc, width: rect.size.width)
                rect.size.height = self.tgValidMeasure(sbv.tg_height, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                
            }
            
            //计算yPos的值加上topSpace + rect.size.height + bottomSpace + lsc.tg_vspace 的值要小于整体的宽度。
            var place:CGFloat = yPos + topSpace + rect.size.height + bottomSpace
            if arrangedIndex != 0 {
                place += vertSpace
            }
            place += lsc.tg_bottomPadding
            
            //sbv所占据的宽度要超过了视图的整体宽度，因此需要换行。但是如果arrangedIndex为0的话表示这个控件的整行的宽度和布局视图保持一致。
            if place - selfSize.height > 0.0001
            {
                yPos = lsc.tg_topPadding
                xPos += horzSpace
                xPos += colMaxWidth
                
                //计算每行Gravity情况
                arrangeIndexSet.insert(i - arrangedIndex)
                self.tgCalcHorzLayoutSingleLineGravity(selfSize, colMaxHeight: colMaxHeight, colMaxWidth: colMaxWidth, mg: mgvert, amg: amghorz, sbs: sbs, startIndex: i, count: arrangedIndex, vertSpace: vertSpace, horzSpace: horzSpace, isEstimate: isEstimate, lsc:lsc)
                
                //计算单独的sbv的高度是否大于整体的高度。如果大于则缩小高度。
                if (topSpace + bottomSpace + rect.size.height > selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding)
                {
                    rect.size.height = selfSize.height - lsc.tg_topPadding - lsc.tg_bottomPadding - topSpace - bottomSpace
                    rect.size.height = self.tgValidMeasure(sbvsc.tgHeight, sbv: sbv, calcSize: rect.size.height, sbvSize: rect.size, selfLayoutSize: selfSize)
                }
                
                colMaxWidth = 0;
                colMaxHeight = 0;
                arrangedIndex = 0;
            }
            
            if arrangedIndex != 0 {
                yPos += vertSpace
            }
            rect.origin.x = xPos + leadingSpace
            rect.origin.y = yPos + topSpace
            yPos += topSpace + rect.size.height + bottomSpace
            
            if (colMaxWidth < leadingSpace + trailingSpace + rect.size.width) {
                colMaxWidth = leadingSpace + trailingSpace + rect.size.width;
            }
            
            if (colMaxHeight < (yPos - lsc.tg_topPadding)) {
                colMaxHeight = (yPos - lsc.tg_topPadding);
            }
            sbvtgFrame.frame = rect;
            
            arrangedIndex += 1;
        }
        
        //最后一行
        arrangeIndexSet.insert(sbs.count - arrangedIndex)
        self.tgCalcHorzLayoutSingleLineGravity(selfSize, colMaxHeight: colMaxHeight, colMaxWidth: colMaxWidth, mg: mgvert, amg: amghorz, sbs: sbs, startIndex: sbs.count, count: arrangedIndex, vertSpace: vertSpace, horzSpace: horzSpace,isEstimate: isEstimate, lsc:lsc)
        
        if let t = lsc.tgWidth, t.isWrap {
            selfSize.width = xPos + lsc.tg_trailingPadding + colMaxWidth
        }
        else {
            var addXPos:CGFloat = 0
            var between:CGFloat = 0
            var fill:CGFloat = 0
            
            if (mghorz == TGGravity.horz.center)
            {
                addXPos = (selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos) / 2;
            }
            else if (mghorz == TGGravity.horz.trailing)
            {
                addXPos = selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos;
            }
            else if (mghorz == TGGravity.horz.fill)
            {
                if (arrangeIndexSet.count > 0)
                {
                   fill = (selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos) / CGFloat(arrangeIndexSet.count)
                }
            }
            else if (mghorz == TGGravity.horz.between)
            {
                if (arrangeIndexSet.count > 1)
                {
                  between = (selfSize.width - lsc.tg_trailingPadding - colMaxWidth - xPos) / CGFloat(arrangeIndexSet.count - 1)
                }
            }

            
            if (addXPos != 0 || between != 0 || fill != 0)
            {
                var line:CGFloat = 0
                var lastIndex:Int = 0
                
                for i in 0..<sbs.count {
                    let sbv:UIView = sbs[i]
                    let sbvtgFrame = sbv.tgFrame
                    sbvtgFrame.leading += addXPos
                    
                    let index = arrangeIndexSet.integerLessThanOrEqualTo(i)
                    if lastIndex != index
                    {
                        lastIndex = index!
                        line += 1
                    }
                    
                    sbvtgFrame.width += fill
                    sbvtgFrame.leading += fill * line
                    sbvtgFrame.leading += between * line
                }
            }
        }
        
        return selfSize
    }
}
