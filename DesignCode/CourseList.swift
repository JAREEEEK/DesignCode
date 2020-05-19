//
//  CourseList.swift
//  DesignCode
//
//  Created by Yaroslav Nosik on 16.05.2020.
//  Copyright © 2020 Yaroslav Nosik. All rights reserved.
//

import SwiftUI
import Contentful
import SDWebImageSwiftUI

struct CourseList: View {
    @ObservedObject var store = CourseStore()
    @State var active = false
    @State var activeIndex = -1
    @State var activeView = CGSize.zero
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        GeometryReader { bounds in
            ZStack {
                Color.black.opacity(Double(self.activeView.height/500))
                    .animation(.linear)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 30.0) {
                        Text("Courses")
                            .font(.largeTitle).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 30)
                            .padding(.top, 30)
                            .blur(radius: self.active ? 20 : 0)
                        
                        ForEach(self.store.courses.indices, id: \.self) { index in
                            GeometryReader { geometry in
                                CourseView(
                                    show: self.$store.courses[index].show,
                                    active: self.$active,
                                    activeIndex: self.$activeIndex,
                                    activeView: self.$activeView,
                                    course: self.store.courses[index],
                                    index: index,
                                    bounds: bounds
                                )
                                    .offset(y: self.store.courses[index].show ? -geometry.frame(in: .global).minY : 0)
                                    .opacity(self.activeIndex != index && self.active ? 0 : 1)
                                    .scaleEffect(self.activeIndex != index && self.active ? 0.5 : 1)
                                    .offset(x: self.activeIndex != index && self.active ? bounds.size.width : 0)
                            }
                            .frame(height: self.horizontalSizeClass == .regular ? 80 : 280)
                            .frame(maxWidth: self.store.courses[index].show ? 712 : getCardWidth(bounds: bounds))
                            .zIndex(self.store.courses[index].show ? 1 : 0)
                        }
                    }
                    .frame(width: bounds.size.width)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
                }
                .statusBar(hidden: self.active)
                .animation(.linear)
            }
        }
    }
}

func getCardWidth(bounds: GeometryProxy) -> CGFloat {
    if bounds.size.width > 712 {
        return 712
    }
    
    return bounds.size.width - 60
}

func getCardCornerRadius(bounds: GeometryProxy) -> CGFloat {
    if bounds.size.width < 712 && bounds.safeAreaInsets.top < 44 {
        return 0
    }
    
    return 30
}

struct CourseList_Previews: PreviewProvider {
    static var previews: some View {
        CourseList()
    }
}

struct CourseView: View {
    @Binding var show: Bool
    @Binding var active: Bool
    @Binding var activeIndex: Int
    @Binding var activeView: CGSize
    var course: Course
    var index: Int
    var bounds: GeometryProxy
    
    var body: some View {
        ZStack(alignment: .top) {
            
            VStack(alignment: .leading, spacing: 30) {
                Text("Take your SwiftUI app to the App Store with advanced techniques like API data, packages and CMS.")
                
                Text("About this course")
                    .font(.title).bold()
                
                Text("This course is unlike any other. We care about design and want to make sure that you get better at it in the process. It was written for designers and developers who are passionate about collaborating and building real apps for iOS and macOS. While it's not one codebase for all apps, you learn once and can apply the techniques and controls to all platforms with incredible quality, consistency and performance. It's beginner-friendly, but it's also packed with design tricks and efficient workflows for building great user interfaces and interactions.")

                    Text("Minimal coding experience required, such as in HTML and CSS. Please note that Xcode 11 and Catalina are essential. Once you get everything installed, it'll get a lot friendlier! I added a bunch of troubleshoots at the end of this page to help you navigate the issues you might encounter.")
            }
            .padding(30)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? .infinity : 280, alignment: .top)
            .offset(y: show ? 460 : 0)
            .background(Color("background2"))
            .clipShape(RoundedRectangle(cornerRadius: show ? getCardCornerRadius(bounds: bounds) : 30, style: .continuous))
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
            .opacity(show ? 1 : 0)
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 8.0) {
                        Text(course.title)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                        Text(course.subtitle)
                            .foregroundColor(Color.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Image(uiImage: course.logo)
                            .opacity(show ? 0 : 1)
                        
                        VStack {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                        }
                        .frame(width: 36, height: 36)
                        .background(Color.black)
                        .clipShape(Circle())
                        .opacity(show ? 1 : 0)
                    }
                }
                
                Spacer()
                
                WebImage(url: course.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 140, alignment: .top)
            }
            .padding(show ? 30 : 20)
            .padding(.top, show ? 30 : 0)
            .frame(maxWidth: show ? .infinity : screen.width - 60, maxHeight: show ? 460 : 280)
            .background(Color(course.color))
            .clipShape(RoundedRectangle(cornerRadius: show ? getCardCornerRadius(bounds: bounds) : 30, style: .continuous))
            .shadow(color: Color(course.color).opacity(0.3), radius: 20, x: 0, y: 20)
            .gesture(
                show ?
                    DragGesture().onChanged { value in
                        guard value.translation.height < 300,
                            value.translation.height > 0 else { return }
                        self.activeView = value.translation
                    }
                    .onEnded { value in
                        if self.activeView.height > 50 {
                            self.show = false
                            self.active = false
                            self.activeIndex = -1
                        }
                        self.activeView = .zero
                    }
                    : nil
            )
            .onTapGesture {
                self.show.toggle()
                self.active.toggle()
                self.activeIndex = self.show ? self.index : -1
            }
            
            if show {
//                CourseDetail(course: course, show: $show, active: $active, activeIndex: $activeIndex)
//                    .background(Color.white)
//                    .animation(nil)
            }
        }
        .frame(height: show ? bounds.size.height + bounds.safeAreaInsets.top + bounds.safeAreaInsets.bottom : 280)
        .scaleEffect(1 - self.activeView.height / 1000)
        .rotation3DEffect(Angle(degrees: Double(self.activeView.height / 10)), axis: (x: 0, y: 10.0, z: 0))
        .hueRotation(Angle(degrees: Double(self.activeView.height)))
        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
        .gesture(
            show ?
                DragGesture().onChanged { value in
                    guard value.translation.height < 300,
                        value.translation.height > 0 else { return }
                    self.activeView = value.translation
                }
                .onEnded { value in
                    if self.activeView.height > 50 {
                        self.show = false
                        self.active = false
                        self.activeIndex = -1
                    }
                    self.activeView = .zero
                }
                : nil
        )
        .edgesIgnoringSafeArea(.all)
    }
}

struct Course: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String
    var imageURL: URL?
    var logo: UIImage
    var color: UIColor
    var show: Bool
    let colors = [#colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1), #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1), #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1), #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1), #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1), #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)]
    
    init(title: String, subtitle: String, imageURL: URL?, logo: UIImage, color: UIColor, show: Bool) {
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.logo = logo
        self.color = color
        self.show = show
    }
    
    init(with item: Entry) {
        self.title = item.fields["title"] as? String ?? ""
        self.subtitle = item.fields["subtitle"] as? String ?? ""
        self.imageURL = item.fields.linkedAsset(at: "image")?.url
        self.logo = #imageLiteral(resourceName: "Logo1")
        self.color = colors.randomElement() ?? #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1)
        self.show = false
    }
}

var courseData = [
   Course(title: "Prototype Designs in SwiftUI", subtitle: "18 Sections", imageURL: URL(string: "https://cvws.icloud-content.com/B/AZzRQU5mEAsOU1x3mWhlGZO2FHyzAVpnP5avwZ4olXpEG_OEZUjDcLE6/Card1%402x.png?o=Ava4xac-eI4fbInTa241L92jEvxRTwiFlewSksGboh1K&v=1&x=3&a=CAog_ycw5u_LlEcz_IvSBDUk-04ewgeBLkqA3eNBsgcpXFESHRDKpLe4oi4Y6pvuuKIuIgEAUgS2FHyzWgTDcLE6&e=1589794016&k=4-Mgx6m2ltFsiX3EwrCpKA&fl=&r=07035ef4-026f-4833-887f-f9cc41e00504-1&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=67&s=QVF3vuqU31eoDkREsXmR1Z8Le-I&cd=i"), logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1), show: false),
   Course(title: "SwiftUI Advanced", subtitle: "20 Sections", imageURL: URL(string: "https://cvws.icloud-content.com/B/AZzRQU5mEAsOU1x3mWhlGZO2FHyzAVpnP5avwZ4olXpEG_OEZUjDcLE6/Card1%402x.png?o=Ava4xac-eI4fbInTa241L92jEvxRTwiFlewSksGboh1K&v=1&x=3&a=CAog_ycw5u_LlEcz_IvSBDUk-04ewgeBLkqA3eNBsgcpXFESHRDKpLe4oi4Y6pvuuKIuIgEAUgS2FHyzWgTDcLE6&e=1589794016&k=4-Mgx6m2ltFsiX3EwrCpKA&fl=&r=07035ef4-026f-4833-887f-f9cc41e00504-1&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=67&s=QVF3vuqU31eoDkREsXmR1Z8Le-I&cd=i"), logo: #imageLiteral(resourceName: "Logo1"), color: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1), show: false),
   Course(title: "UI Design for Developers", subtitle: "20 Sections", imageURL: URL(string: "https://cvws.icloud-content.com/B/AZzRQU5mEAsOU1x3mWhlGZO2FHyzAVpnP5avwZ4olXpEG_OEZUjDcLE6/Card1%402x.png?o=Ava4xac-eI4fbInTa241L92jEvxRTwiFlewSksGboh1K&v=1&x=3&a=CAog_ycw5u_LlEcz_IvSBDUk-04ewgeBLkqA3eNBsgcpXFESHRDKpLe4oi4Y6pvuuKIuIgEAUgS2FHyzWgTDcLE6&e=1589794016&k=4-Mgx6m2ltFsiX3EwrCpKA&fl=&r=07035ef4-026f-4833-887f-f9cc41e00504-1&ckc=com.apple.clouddocs&ckz=com.apple.CloudDocs&p=67&s=QVF3vuqU31eoDkREsXmR1Z8Le-I&cd=i"), logo: #imageLiteral(resourceName: "Logo3"), color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1), show: false)
]
