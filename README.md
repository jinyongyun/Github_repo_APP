# Github_repo_APP
[RxSwift] RxSwift와 RxCocoa를 이용한 깃헙 레포 앱!

해당 정리를 먼저 읽고 오면 더 편하다!

[RxSwift 정리(+MVVM)](https://www.notion.so/RxSwift-MVVM-53d3c5006bd74319b261f1ce3b7f5951?pvs=21) 

저번에 선언형 프로그래밍 방식으로 앱을 만들 수 있는 SwiftUI에 대해서 배웠다.

이번에는 같은 선언형 프로그래밍 방식이지만, 조금…아니 많이 다른 RxSwift에 대해서 배우고

이를 기반으로 Github 앱을 만들어보려고 한다.

종종 취업공고에서 우대조건에 RxSwift가 쓰여있는 것이 보인다.

그렇다면 왜 RxSwift를 알아야 할까? 왜 우대조건에 많이 보이는 걸까?

무엇보다 Rx가 대체 뭐가 좋은걸까….

Rx는 기본적으로 비동기적으로 움직이는 애플의 API들과 수시로 상태가 변하는 환경에서 보다 직관적이고 

효율적인 코드를 작성할 수 있게 도와준다.(더 자세한 내용은 RxSwift 정리에서!)

몇 가지 예시를 한 번 둘러보자(공식문서에서 가져왔다.)

```swift
Observable
	.combineLatest(
			firstName.rx.text,
			lastName.rx.text
	) { $0 + " " + $1 }
	.map {"Greetimgs, \($0)" }
	.bind(to: greetingLabel.rx.text)
	.disposed(by: disposeBag)
```

위의 코드를 보면 Observable이라는 것이 보이는데, 이녀석은 .bind라는 걸 통해서 UI 코드를 작성한다.

정확이 말하자면, 이 .bind는 RxCocoa라는 곳에서 제공하는 기능이다. 구체적인 건 밑에서 더 자세히 알아볼 것이다. 어쨌든 Rx에서는 Observable이라는 객체를 통해 이벤트의 흐름을 표현하게 된다.

그리고 .comebineLastest .map 등과 같은 오퍼레이터들을 통해 Observable이 내뱉는 이벤트 속의 값들을 여러 형태로 조합하고 변경한다.

예를 들어 combineLatest라는 오퍼레이터는 다른 Observable에서 나오는 값들을 조합할 수 있게 하는 오퍼레이터이고, map은 기존의 배열에서 다루는 map과 동일하다. 그러면 대충 흐름이 보이지 않는가?

combineLatest에서 firstName.rx.text와 lastName.rx.text를 $0 + " " + $1 이 형태로 묶고

이게 mapping되어 "Greetimgs, \( $0 + " " + $1)" 요렇게 되지 않을까?

그러면 이건 bind를 통해 greetingLabel이라는 곳의 text로 전달될 것이다.

이렇게 bind를 쓰면 우리가 dispatchQueue를 통해 조정해줘야 했던(백그라운드 스레드에서 돌았다면 UI를 표시하기 위해 메인 스레드로 돌려줘야한다던가..왜? Ui 주기적 업데이트는 메인 스레드에서 하니까!) 설정들을 자동적으로 처리해준다.

우리는 앞으로 Rx를 통해 이러한 형태의 코드를 많이 작성하게 될 것이다.

또 다른 예제를 한 번 살펴보자

```swift
func doSomethingIncredible(forWho: String) throws -> IncredibleThing 
```

우리는 지금까지 그리고 앞으로도 수많은 API 통신을 기반으로 하는 앱을 만들게 될 것이다.

문제는 API 콜이 항상 성공하는 건 아니라는 것이다.

그럼 개발하는 입장에서는 실패했을 때 한 세 번 정도는 시도를 해 볼 수 있도록 설정해놓으면 좋을 것이다.

만약 위의 함수가 API 함수라고 한다면,

함수의 내용이 실패했을 경우 재시도 하기가 어렵다.

실패여부와 관계없이 함수를 무조건 3번 호출한다면…이건 재시도가 아니다.

구현이 굉장히 복잡할 것이다. 아마 예외처리로 빼서 거기서 반복을 돌린다고 하더라도

분명 재사용 할 수 없는 상태들이 나올 것이다.(코드에서 표현되지 않더라도)

But!  Rx에는 기본적으로 제공하는 retry라는 operator가 있다!!!(외쳐 RX!!!)

```swift
   doSomethingIncredible("me")
      .retry(3)
```

또다른 예로는 delegate가 있다.

우리가 scrollView가 움직였는지 확인하려면 아래의 형태의 scrollView Delegate를 구현해야 한다.

```swift
public func scrollViewDidScroll(scrollView: UIScrollView) { [weak self]
	self?.leftPsitionConstraint.connstant = scollView.contentOffset.x
}
```

코드만 봤을 땐, 여러개 스크롤 뷰 중에 어떤 스크롤 뷰에 명령하는건지 알 수 없다.

또 델리게이트를 별도로 선언해줘야 한다. 즉 명시적이지가 않다!

```swift
self.resultsTableView.rx.contentOffset
	.map { $0.x }
	.bind(to: self.leftPositionConstraint.rx.constant)
```

하지만 rx를 사용하면 훨씬 직관적인 표현이 가능하다. 이 resultTableView가 갖고 있는 ScrollView의 offset을 원하는 곳에 바인딩 해주고 있다.

앞선 코드와 동일하지만, 의미상 알아보기는 훨씬 쉽다.

적은 예시들을 봤지만, 이외에도

NotificationCenter나 delegate pattern

GCD 그리고 Closure 등과 같은 애플에서 제공하는 비동기 코드를 작성할 수 있는 다양한 API 대신

보다 더 직관적이고 효율적인 Rx를 쓸 수 있다.

일반적으로 대부분의 클래스들은 비동기적으로 작업을 수행하고

모든 UI 구성요소들은 본질적으로 비동기이다.

따라서 내가 어떤 코드를 작성했을 때 정확히 매번 어떤 순서로 작성될 지 가정하는 것은 불가능하다.

앱의 코드는 사용자 입력이나 네트워크 활동 또는 기타 OS 이벤트와 같은 다양한 요인에 따라

완전히 다른 순서로 실행될 수 있기 때문이다.

결국 문제는 애플의 SDK 내의 API를 통한 복합적인 비동기 코드는 부분별로 나눠쓰기 매우 어렵거나

개발자가 추적하는 건 거의 불가능하다는 것이다.

```swift
override func viewWillAppear(_ animated: Bool) {
	super.viewWillAppear(animated)
		
	makeUI()
	connectUIControls()
	fetchData()
	checkForChanges()
}
```

만약 우리가 viewWillAppear에 다음과 같이 함수들을 작성했다고 해보자.

다 좋지만, 우리는 인간이고, 인간은 복잡하고 비동기적인 앱을 만들기 위해 명령형 코드를 사용하는 것이 너무나 어렵다.

이 각각의 메서드 안에서 무슨 동작을 수행하는지 어떤 순서로 실행되는지 알기 너무 어렵다.(보장도 안된다)

함수 안에서 어떤 요소를 바꾸고 있는지, 어떤 부수적인 작용을 일으키는지 우리가 정확히 인지하고 있는 것이 중요하다.

Rx는 이러한 이슈를 추적가능하도록 해준다.

Rx를 사용했을 때의 Benefit은 다음과 같다.

- Composable
- Reusable
- Declarative
- Understandable and concise
- Stable
- Less stateful
- Without leaks

조합가능하고, 재사용 가능하다.

선언형이라 정의를 변경하는 것이 아니라, 오퍼레이터를 통해 데이터만 변경한다.

이런 특성들 덕분에 Rx를 사용한 코드는 이해하기 쉽고, 간결하다.

**우리는 이런 Rx를 이용해 깃헙의 오픈 API를 이용해서 Apple github의 repository 목록을 가져와 UITableView에 뿌려줄 것이다!!**

<details>
  <summary><b>RxSwift 알아보기</b></summary>
  우리가 작성하는 코드의 대부분은 외부 응답과 관련된 것이다

예를 들면 IBAction이라든지, 키보드를 관찰하는 Notification이라든지

또 URLSession이 데이터로 응답할 때 실행할 클로저를 제공해야 한다.

이러한 다양한 시스템은 모든 코드를 불필요하고 복잡하게 만든다(각자 방식이 다르니까…)

모든 코드에서 일관되게 작동하는 반응이 있다면 더 좋지 않을까? → 이러한 질문에서 시작한 것이 바로 RxSwift이다.

RxSwift를 다루기 위해 가장 기본적으로 알아야 하는 개념으로 **Observable**이란 것이 있다.

단어 자체는 생소하게 느껴질 수도 있지만, Swift에서의 Sequence와 동일하다.

Sequence는 뭐였나? array 등 개개인의 element를 하나씩 순회할 수 있는 타입이 바로 Sequence 아닌가! 공식문서에서는 Observable을 다음과 같이 표현한다.

“Every Observable instance is just a sequence”

이 밖에서 RxSwift를 이해하기 위해 알아야 할 구성요소가 있다.

- Observable
- Operator : 다양한 형태로 값을 걸러내거나, 변환하거나, 합치는 연산자들
- Scheduler : 우리가 직접 생성하고 커스텀 할 일은 거의 X, Rx에서의 DispatchQueue

하나씩 간략하게 살펴보자.

### **Observable**

```swift
Observable<T>
```

Observable 클래스는 Rx 코드의 기반이 된다.

General 형태로 표현한 T 형태의 데이터 스냅샷을 전달할 수 있는 일련의 이벤트를 비동기적으로 생성하는 기능을 한다. → 다른 클래스에서 만든 값을 시간에 따라 읽을 수 있다!

하나 이상의 observers(관찰자)가 실시간으로 어떤 이벤트에 반응하게 된다. 

아래의 세 가지 유형의 이벤트만 방출한다.

```swift
enum Event<Element> {
	case next(Element)                 //sequence의 다음 element를 전달한다.
	case error(Swift.Error)            //sequence의 진행이 error와 함께 failed
	case completed                     //sequence가 성공적으로 terminated
}
```
![Untitled (Draft)-1 6](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/ed2c72b0-922b-40e9-b953-ce932ba3e8f5)


그림으로 한 번 방금 알아본 개념을 확인해보자.

시간에 걸쳐서 발생하는 비동기 이벤트가 있다고 해보자.

이렇게 시간 축을 따라 우측으로 갈수록 일이 진행된 것을 의미하고

여기서 T는 Int라 Int 타입의 값을 하나씩 하나씩 이벤트로 내뱉는 Observable이 있는 것이다.

1,3,5,7,9라는 element들을 next 이벤트에 담아서 이 Observable은 내보내게 되는데

내보냈을 때, 이 Observable에 반드시 Observer 즉 관찰자들이 관찰을 하고 있어야 

이 element들을 수신할 수 있다.

하나 더 보자.
![Untitled (Draft)-2 4](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/0355200e-6e4b-4cd7-8067-3e3b90a0b096)


이번에는 Data 타입이다. 이 Observable은 data 또는 다른 값을 방출한 다음에

성공적으로 또는 에러를 통해 종료되게 된다.

인터넷 상에서 파일을 한 번 다운로드 받는 코드를 상상해 보라!

시간에 흐름에 따라 다운로드를 시작할거고, 다운로드의 percentage가 올라갈거고

만약 네트워크 연결이 도중에 끊어진다면 다운로드가 정지하고, 에러를 표시할 것이다.

혹은 성공적으로 완료할 수도 있겠지…

이러한 흐름은 앞에서 설명한 Observable의 생명주기와 정확히 일치한다.

```swift
Network.download(file: "https://www...")
	.subscrube(onNext: { data in
    // 임시 파일에 데이터 추가
},
onError: { error in
     // 사용자에게 에러 표현
},
onCompleted: {
    // 다운로드 된 파일 사용
})
```

RxSwift 코드로 표현하면 위와 같이 표현할 수 있다.

Network.download로 표현된, 이 네트워크로 들어오는 데이터 값을 방출하는 어떠한 Observable 데이터 instance를 상상해보자. (여기서 Network.download로 표현됐지만, 앞에 그림에서 본 Data 타입ㅇ다) subscribe이라는 메서드를 통해 수신을 하게 되면 관찰자가 이 Observable을 보게 된다.

이렇게 하면 onNext라는 이벤트를 통해 데이터를 하나씩 받게 된다.

또는 onError가 발생했다면 에러가 나타났음을 사용자에게 표현할 수도 있다.

최종적으로 onCompleted 이벤트가 발생하면 이 클로저를 통해 completeEvent를 받을 수 있을거고

이를 통해 새로운 viewController를 푸시해서 다운로드 받은 파일의 내용을 표시한다든지 할 수 있을 것이다.

지금처럼 자연적으로 또는 강제적으로 종료되는 파일 다운로드같은 활동과 달리 

단순하게 무한한 Sequence가 있을 수 있다.

보통 UI 이벤트는 무한하게 관찰 가능한 Sequence인데

예를 들어 기기의 괄호, 세로 모드에 따라 반응해야하는 코드를 살펴보자.

UIDevice orientation didchange 옵저버를 추가할거다.

```swift
UIDevice.rx.orientation
	.subscribe(onNext: { current in
         switch current {
         case .landscape:
             //가로모드 배치
         case .portrait:
               //세로모드 배치
        {
     })
```

방향 전환을 할 수 있는 쿼리 메서드를 제공해야한다.

그래서 UIDevice의 현재 방향값을 확인한 뒤,

이 값에 따라 화면이 표시될 수 있도록 해야한다.

방향 전환이 가능한 디바이스가 존재하는한 이런 연속적인 방향전환은 무한히 관찰할 수 있다.

따라서 항상 최초값을 가져야 하고, 사용자가 디바이스를 절대 회전하지 않는다고 해서

이벤트가 종료됐다고 보긴 어렵다. 단지 이벤트가 발생한 적이 없을 뿐이다.

이걸 RxSwift 코드로 표현하면 위의 코드와 같다.  

orientation 즉 방향을 알 수 있고

이 방향을 받아 앱의 UI에 업데이트 할 수 있을 것이다.

### Operator

Observable 클래스에는 보다 복잡한 논리를 구현하기 위해서 함께 구성되는 많은 메서드가 포함되어 있다. 이러한 메서드는 각자가 아주 독립적이고, 여러 메서드가 조합이 되어 하나의 구문을 구성할 수 있다.

우리는 이것을 Operator 즉 연산자라고 한다.

이러한 Operator들은 주로 비동기 입력을 받아 출력만 생성하기 때문에 퍼즐 조각처럼

자기들끼리 조합하고 결합할 수 있다.

위에서 보았던 방향 전환에 대한 예제에 Rx 연산자인 filter와 map을 적용시킨 코드이다.

```swift
UIDevice.rx.orientation
	.filter { value in
			return value != .landscape
	}
	.map { _ in
		return "세로로만 볼겁니다!"
  }
  .subscribe(onNext: { string in
       showAlert(text: string)
  })
```

제일 첫번째 줄에 있는 UIDevice.rx.orientation이 orientation 타입을 갖는 하나의 observable이다.

이 하나의 observable을 filter map과 같은 연산자들이 각각의 결과값을 조합하고 변형한 다음에 내뱉고

있다.

먼저 filter는 landscape 즉 가로 모드가 아닌 값만을 내놓고 있다.

즉 디바이스가 가로 모드라면 아래의 코드는 실행되지 않을 것이다.

만약 세로 값이 들어오면 map으로 가서 스트링 출력으로 변환할 것이다.

마지막으로 subscribe를 통해 결과로 onNext를 구현하게 된다.

string을 전달받고, 전달받은 string을 Alert화면에 보여주는 가상의 메서드를 호출하게 되는데

연산자들은 언제나 입력된 데이터를 통해 결과값을 출력하기 때문에

단일 연산자보다 조합을 했을 때 훨씬 다양하게 표현할 수 있다.

### Scheduler

스케쥴러는 dispatchQueue와 동일한 것이라고 말했다.

다만 훨씬 강력하고 쓰기 쉬울 뿐이다.

RxSwift에는 여러가지 Scheduler가 이미 정의되어 있고

대부분의 상황에서 사용가능하기 때문에 우리 개발자가 자신만의 스케줄러를 생성할 일은 거의 없다.

보통 데이터를 관찰하고, 데이터에 따라 UI를 업데이트 하는 일이 사실상 대부분의 일이기 때문에

그렇게 깊게 다룰 이유가 없다.

기존까지 GCD를 통해서 일련의 코드를 작성했다면

Scheduler를 통한 RxSwift는 다음 그림과 같이 이루어진다.
![Untitled (Draft)-3 4](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/eabec675-5bdf-4eb0-afe4-d08855d7b7d4)

</details>

<details>
  <summary><b>RxSwift 설치하기</b></summary>
  ```swift
pod 'RxSwift', '6.0.2'
```
  RxSwift는 그동안 우리가 외부 라이브러리를 설치한 방식 그대로 설치할 수 있다.

더 자세한 내용은 위의 RxSwift 공식 라이브러리(깃허브)로 가면 볼 수 있다.

이번에는 오랜만에 Cocoapods을 이용해서 설치해보자.

```swift
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'RxSwift', '6.6.0'
    pod 'RxCocoa', '6.6.0'
end
```

먼저 GitHubRepository라는 xcode 프로젝트를 만들어줬다.

일단 UI는 storyboard로 설정해줬다.

과정은 기억하는가 모르겠다.

<img width="746" alt="스크린샷 2024-01-28 오후 7 59 54" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/f9c0c436-3932-4643-a438-cabbf7d06a29">

pod init 한 다음, 저 위에 저녀석 넣어주고, 다시 pod install 해주면 끝!

빌드가 제대로 됐다면 오류가 나지 않을 것이다.

</details>

<details>
  <summary><b>Observable 알아보기</b></summary>
  - Rx의 심장
  - Observable = Observable Sequence = Sequence
  - 비동기적(asynchronous)
  - Observable들은 일정 기간 동안 계속해서 이벤트를 생성 (emit : 방출)
  - marble diagram: 시간의 흐름에 따라서 값을 표시하는 방식 - 을 통해 잘 파악할 수 있다!
  
  각 오퍼레이터의 시간에 따른 marble diagram을 [RxMarbles](https://rxmarbles.com/) 사이트에서 볼 수 있다.

  위에서 잠깐 살펴보았던, Observable의 라이프 사이클의 종료 방식은 다음과 같이 두 가지로 나뉘어진다.

  ![Untitled (Draft)-2 4](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/92fedca3-4e2d-4461-ba5f-9d501ff76379)

  - Observable은 어떤 구성요소를 갖는 next 이벤트를 계속해서 방출할 수 있다.
  - Observable은 error 이벤트를 방출하여 완전 종료될 수 있다.
  - Observble은 complete 이벤트를 방출하여 완전 종료 될 수 있다.

  이제 RxSwift의 소스 코드 예제를 살펴보면서 이벤트에 대해 파헤쳐보자.

```swift
//Represents a sequence event.
//Sequence grammar:
// **next\* (error | completed)**
@frozen public enum Event<Element> {
      //Next element is produced.
    case next(Element)

      // Sequence terminated with an error
    case error(Swift.error)

      //Sequence completed successfully
    case completed
}
```

이벤트들은 enum 클래스로 표현되고 있는데,

next 이벤트는 어떤 element 인스턴스를 갖고 있는 것을 알 수 있다. (엄밀히 말하자면 연관값이지…)

error 이벤트는 연관값으로 Swift.Error 타입을 받고

completed 이벤트는 단순하게 이벤트를 종료시키기만 한다.

코드만 살펴보는 것보단 직접 한 번 만들어보자.

RxSwiftPractice 프로젝트를 만들어 Rx의 Observable을 직접 만들어보며 작동시켜보자.

pod init으로 pod 파일을 만들고, 안에 RxCocoa와 RxSwift를 넣고 install 해준다.

이제 워크스페이스 파일을 열고, viewController에서 RxSwift를 사용해보는 것이 아닌

그저 연습 용도로 Observable이 어떻게 생성되고 어떤 형태로 이벤트를 내뱉는지 확인만 해볼 것이다.

새 파일을 생성하는데, 빈 플레이그라운드 파일을 선택한다.

일단 Foundation과 RxSwift 라이브러리만 import 해줬다.

이제 여기서 Observable을 직접 만들어 볼 것이다.

Observable을 만드는 방식에는 여러가지가 있다.

여러가지 연산자를 통해서 만들 수가 있는데 아래의 코드에 네가지 방식을 적어두었다.


```swift
import Foundation
import RxSwift

/*onNext를 통해 어떤 형태의 이벤트를 방출할지 선택
just 오퍼레이터는 이름에서 알 수 있듯이 단지 하나의 element만 방출
하나의 요소만 포함하는 Observable Sequence 생성*/
print("-----just-----")
Observable<Int>.just(1)

/*
 Of는 다양한 이벤트를 넣을 수 있도록 해주는 오퍼레이터
 */
print("-----Of1-----")
Observable<Int>.of(1, 2, 3, 4, 5)

/*
 이렇게 넣으면 타입 추론도 가능
 just연산자와 사실상 동일 -> 하나의 배열만을 방출해서
 각각 배출하려면 위에처럼 하나씩 넣야하거나, From을 사용해야함
 */
print("-----Of2-----")
Observable.of([1, 2, 3, 4, 5])

/*
 배열만 받는 입맛이 까다로운 녀석
 이렇게 하면 배열을 받아서 각각의 eleement들을 하나씩 방출
 */
print("-----From-----")
Observable.from([1,2,3,4,5])

/*
 단순하게 위에처럼 Observable을 만들기만 하고 실제로 이벤트가 방출되는지는 어떻게 알 수 있을까?
 Observable은 단순한 Sequence 정의일 뿐이다.
 Observable은 구독(subscriber)되기 전에는 아무 이벤트도 내보내지 않는다.
 */
```

그렇다면 subscribe(구독)은 어떻게 하면 될까?

```swift
import Foundation
import RxSwift

/*onNext를 통해 어떤 형태의 이벤트를 방출할지 선택
just 오퍼레이터는 이름에서 알 수 있듯이 단지 하나의 element만 방출
하나의 요소만 포함하는 Observable Sequence 생성*/
print("-----just-----")
Observable<Int>.just(1)
    .subscribe(onNext: {
        print($0)
    })

/*
 Of는 다양한 이벤트를 넣을 수 있도록 해주는 오퍼레이터
 */
print("-----Of1-----")
Observable<Int>.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
        print($0)
    })

/*
 이렇게 넣으면 타입 추론도 가능
 just연산자와 사실상 동일 -> 하나의 배열만을 방출해서
 각각 배출하려면 위에처럼 하나씩 넣야하거나, From을 사용해야함
 */
print("-----Of2-----")
Observable.of([1, 2, 3, 4, 5])
    .subscribe(onNext: {
        print($0)
    })

/*
 배열만 받는 입맛이 까다로운 녀석
 이렇게 하면 배열을 받아서 각각의 eleement들을 하나씩 방출
 */
print("-----From-----")
Observable.from([1,2,3,4,5])
    .subscribe(onNext: {
        print($0)
    })

/*
 단순하게 위에처럼 Observable을 만들기만 하고 실제로 이벤트가 방출되는지는 어떻게 알 수 있을까?
 Observable은 단순한 Sequence 정의일 뿐이다.
 Observable은 구독(subscriber)되기 전에는 아무 이벤트도 내보내지 않는다.
 */
```
<img width="277" alt="스크린샷 2024-01-29 오후 1 39 22" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/db4666c0-696e-4217-9a15-b3273819914b">



위의 코드를 실제로 실행시킨 결과이다.

Of에서 쉼표로 하나씩 element를 넣어주면

Of1에서처럼 하나씩 이벤트를 발생시키고

Of2처럼 배열을 통으로 넣어주면 배열 하나가 툭하고 통으로 나온다.

이런 형태로 우리는 Observable 시퀀스를 만들고 사용할 수 있다.

이제 Subscribe에 대해 좀 더 자세히 확인해보자.

```swift
/*
 onNext 안쓰고 그냥 subscribe 하면
 next() 이벤트 안에서 element가 표시되고
 이벤트 종료 후에는 completed 이벤트가 발생한다.
 ===================
 -----subscribe1-----
 next(1)
 next(2)
 next(3)
 completed
 */
print("-----subscribe1-----")
Observable.of(1,2,3)
    .subscribe {
        print($0)
    }

/*
 만약 if let 바인딩으로 방출하면?
 옵셔널 해제하듯이 element만 방출
 ==================
 -----subscribe1-----
 1
 2
 3
 */
print("-----subscribe1-----")
Observable.of(1,2,3)
    .subscribe {
        if let element = $0.element {
            print(element)
        }
    }
```

이 밖에도 Observable을 만들 수 있는 또 다른 연산자가 있다.

- empty()

```swift
/*
 요소가 하나도 없는 Observable 만들때
 아무런 이벤트 방출하지 않는다.
 */
print("-------empty-------")
Observable.empty()
    .subscribe {
        print($0)
    }

/*
Void를 타입으로 붙여주면, completed 이벤트가 마지막에 발생
 */
print("-------empty-------")
Observable<Void>.empty()
    .subscribe {
        print($0)
    }

/*
Void를 타입으로 붙여주는 것은 다음과 같다.
Void가 없을 때는 타입추론조차 불가능하기 때문에 아무 것도 안나온다.
 타입을 명시적으로 하면, 그제서야 completed가 나오는 것!
 empty()의 용도로는 두가지가 있다.
 1. 즉시 종료할 수 있는 Observable을 리턴하고 싶을 때
 2. 의도적으로 0개의 값을 가진 Observable을 리턴하고 싶을 때
 */
print("-------empty-------")
Observable<Void>.empty()
    .subscribe(onNext: {
        
    },
    onCompleted: {
       print("Completed")
    })
```

- **never()**

```swift
/*
 never 오퍼레이터
 completed 이벤트조차 표현되지 않는다.
 여기서 <Void>를 붙여도 마찬가지!
 확실히 작동은 하나, 아무것도 내뱉지 않는 것이 never 연산자
 */
print("-------never-------")
Observable.never()
    .subscribe(
        onNext: {
            print($0)
        },
        onCompleted: {
            print("Completed")
        }
    )
```

- **range()**

```swift
/*
 range 오페리이터
 범위에 있는 배열을 start부터 count 크기의 값을 갖도록 만들어준다.
=================
 -------range-------
 2*1=2
 2*2=4
 2*3=6
 2*4=8
 2*5=10
 2*6=12
 2*7=14
 2*8=16
 2*9=18
 */
print("-------range-------")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
        print("2*\($0)=\(2*$0)")
    })
```

- **dispose의 개념**

다시 한 번 말하자면, Observable은 subscribe하지 않으면 아무런 역할도 하지 않는다고 했다.

subscribe가 이벤트를 방출할 수 있도록 하는 방아쇠 역할을 하는 것이다. 따라서 반대로 생각해보면

방아쇠를 당겨서 방출당했던 Observable의 구독을 취소할 수 있지 않을까?

구독을 취소함으로써 Observable을 최종적으로 종료시킬 수 있다. 이 개념을 dispose라고 한다.

```swift
/*
 diseposeBag은 각각의 구독에 대해
 하나씩 dispose로 관리하는 것은 비효율적이라고 여겨
 disposable 타입 배열을 갖고 있는 DisposeBag 인스턴스를 이용해
 (disposable은 disposeBag이 할당해제 하려고 할 때마다 이 dispose()를 호출하게 된다.)
 subscribe로부터 방출된 리턴값을 즉시 disposeBag에 추가하는 것이다.
 이렇게 하면 disposeBag은 이녀석을 잘 갖고 있다가 자신이 할당해제 할 때
 모든 구독에 대해 dispose를 날리는 것이다!
 
 만약 수동적으로 dispose 하는 걸 빼먹으면 메모리 누수가 일어난다.
 Observable이 끝나지 않기 때문
 */

let disposeBag = DisposeBag()

print("-------disposeBag-------")
Observable.of(1,2,3)
    .subscribe {
        print($0)
    }
    .disposed(by: disposeBag)
```

- **create()**

```swift
/*
 create는 escaping 클로저이다.
 이 클로저에는 AnyObserver<_>라는 escaping이 있어서
 이 AnyObserver를 받고, Disposable을 리런하는 형태의 클로저이다.
 AnyObserver는 그냥 제네릭 타입이고, Observable 사퀀스에 값을 쉽게 추가할 수 있게 하는 녀석이다.
 이렇게 추가된 element는 subscribe를 했을 때 방출될 것이다.
 
 코드를 살펴보면 onNext이벤트를 옵저버에 추가했다.
 당연히 중간에 onCompleted 이벤트가 발생해서 2는 방출되지 않을 것이다.
 */

let disposeBag = DisposeBag()

print("-------disposeBag-------")
Observable.create { observer -> Disposable in
    observer.onNext(1) // 이건 observer.on(.next(1)) 과 똑같다.
    observer.onCompleted()
    observer.onNext(2)
    return Disposables.create()
}
.subscribe {
    print($0)
}
.disposed(by: disposeBag)
```

- **deferred()**
```swift
/*
 Observable을 감싸는 Observable
 안에 있는 Observable의 element를 하나씩 내뱉음
 도대체 이건 어떨 때 쓰는 걸까?
 다음 예제에서 확인하자.
 */

let disposeBag = DisposeBag()
print("-----deferred-----")
Observable.deferred {
    Observable.of(1, 2, 3)
}
.subscribe {
    print(1)
}
.disposed(by: disposeBag)

/*
 뒤집기의 상태에 따라 서로 다른 Observable을 내보냄
 ==============
 -----deferred2-----
 ☝️
 👎
 ☝️
 👎
 */
print("-----deferred2-----")
var 뒤집기: Bool = false

let factory: Observable<String> = Observable.deferred {
    뒤집기 = !뒤집기
    if 뒤집기 {
        return Observable.of("☝️")
    } else {
        return Observable.of("👎")
    }
}

for _ in 0...3 {
    factory.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
}
```
</details>

<details>
  <summary><b>Single, Maybe, Completable 알아보기</b></summary>
  ingle, Maybe, Completable을 묶어서 trait이라고 표현하기도 한다.

이 세가지는 우리가 지금까지 알아본 Observable보다 좁은 범위의 Observable이다.

그래서 선택적으로 사용 할 수 있다.

이렇게 좁은 범위의 Observable을 사용하는 이유는 코드 가독성을 높이기 위해서이다.

- Single
![그림1](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/2f02358c-3281-46e3-97cc-410f39b9c3f8)


싱글은 .success 이벤트 또는 .error 이벤트를 한 번만 방출하는 Observable이다.

.success는 우리가 기존에 사용했던 next 이벤트와 completed 이벤트를 합친 것과 같다.

이 아이들은 파일 저장이나, 다운로드, 디스크에서의 데이터 로딩과 같이 기본적으로 값을 산출하는 비동기적 연산에 사용된다.

만약 사진을 저장하는 Observable이 있다고 했을 때, 값을 저장하냐 아니면 에러가 나느냐-와 같이

정확히 하나의 요소만을 방출하는 연산자를 래핑할 때 유용하다. 

싱글 시퀀스가 둘 이상의 요소를 방출하는지 구독을 통해 확인하면, 에러가 방출될 수 있는데

싱글같은 경우 마치 우리가 Observable에서 just를 하면 한 가지의 이벤트만 방출하듯이

이벤트를 하나만 방출하고 완전히 종료된다.

싱글을 만들고 싶으면 싱글을 선언한 다음 Observable을 만드는 방식으로 선언할 수 있고

아니면 아무 Observable에 as Single이라고 붙여서 싱글로 변환시킬 수 있다.

- Maybe
![maybe](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/bcf8a173-220d-4422-90b9-85b237fdfe7e)


Maybe는 싱글과 비슷하지만 유일하게 다른 점은 성공적으로 completed 되더라도 아무런 값을 방출하지 않는 형태의 completed를 포함한다. 예를 들면 사진을 갖고 있는 커스텀한 포토 앨범 앱이 있다고 상상해보자.

거기서 만든 앨범명은 UserDefaults에 저장될 것이고, 해당 아이디로 앨범을 열고 사진을 저장할때마다 그 기록이 남을 것이다. 그럼 Maybe를 통해 상황을 관리할 수 있다.

아이디가 여전히 존재한다면 completed 를 방출하고, 만약 유저가 앨범을  삭제하거나 새로운 앨범을 생성했을 때는 .success 이벤트(next)를 새로운 아이디와 함께 방출할 수 있다. 이렇게 하면 UserDefaults가 해당 값을 보존할 수 있을 것이다. 만약 사진을 저장하거나 삭제하는 과정에서 뭔가 잘못되거나 사진 라이브러리에 접근할 수 없는 경우에는 error를 방출할 것이다. 

싱글을 만들었던 것처럼 Maybe를 만들고 싶다면 as Maybe를 붙여서 만들 수 있다.

- Completable

![Completable](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/8857e20d-2c7d-48d8-a3bc-93035b605012)

Completable은 Completed 또는 error만을 방출한다.

하나 기억해야 할 점은 앞에 Single이나 Maybe처럼 as Completable을 붙여서 Completable로 만들 수는 없다!

왜냐하면 Observable은 요소를 방출할 수 있지만, Completable은 그런거 없이 그냥 completed나 error 둘 중에 하나만 방출하기 때문에 원래 값 요소를 방출하는 이상, 이걸 completable로 바꿀 수는 없다.

만약 completable 시퀀스를 생성하고 싶다면 Completable.create()를 통해 생성하는 수밖에 없다.

결국 Completable에서 핵심은 ‘아무 값도 방출하지 않는다!’

값을 방출하지 않는데 도대체 뭔 쓸모가 있냐!! - 라고 말 할 수도 있지만

동기식 연산의 성공 여부를 확인할 때 유용하게 쓰일 수 있다. (다 쓸데가 있는 법이다.)

예를 들면 유저가 작업할 동안 어떤 데이터가 자동으로 저장되는 기능을 만든다고 해보자.

보통 백그라운드 큐에서 비동기적으로 작업하다가 완료가 되면 작은 노티를 띄우거나 alert을 띄울 것이다.

이럴 경우 우리는 완료가 되었는지, 안되었는지만 파악하면 되기 때문에

어떤 값이 필요가 없다!! (다만 에러가 발생했을때 어떤 에러가 발생했는지는 띄워줘야 할 것이다.)

지금까지 알아본 개념을 바탕으로 실제로 Single, Maybe, Completabe을  코드로 작성해보자.

```swift
import Foundation
import RxSwift

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

print("--------Single1---------")
Single<String>.just("✅") //just를 이용해서 내뱉어준다. 싱글은 하나의 이벤트만 방출하고 종료하기 때문
    .subscribe(
        onSuccess: {
            
        },
        onFailure: {
            
        },
        onDisposed: {
            
        }
    )

/*
Observable<String>.just("✅")
    .subscribe(
        onNext: {},
        onError: {},
        onCompleted: {},
        onDisposed: {}
    )
*/
```

 저번시간에 배운 disposeBag 객체와 TraitsError enum을 정의해준다.

보면 subscribe에서 저번과 인자가 조금 다르다.

원래 우리가 봤던 녀석은 아래에 주석처럼 onNext부터 시작한다.

일단 onSuccess는 onNext와 onCompleted를 합친 거고

onFailure는 하나의 error 방출하고 바로 종료

onDisposed는 똑같고…이처럼 의미상으로는 비슷하다.

```swift
import Foundation
import RxSwift

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case single
    case maybe
    case completable
}

/*
 실행 결과
 --------Single1---------
 ✅
 disposed
 */
print("--------Single1---------")
Single<String>.just("✅") //just를 이용해서 내뱉어준다. 싱글은 하나의 이벤트만 방출하고 종료하기 때문
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error: \($0)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)

/*
 실행 결과
 --------Single2---------
 ✅
 disposed
 */
print("--------Single2---------")
Observable<String>.just("✅")
    .asSingle()
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error: \($0.localizedDescription)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)
```

다음과 같이 asSingle을 통해서 싱글로 변환해서 사용할 수 있다.

```swift
/*
 실행 결과
 --------Single2---------
 error: The operation couldn’t be completed. (__lldb_expr_11.TraitsError error 0.)
 disposed
 */
print("--------Single2---------")
Observable<String>
    .create { observer -> Disposable in
    observer.onError(TraitsError.single)
    return Disposables.create()
     }
    .asSingle()
    .subscribe(
        onSuccess: {
            print($0)
        },
        onFailure: {
            print("error: \($0.localizedDescription)")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)
```

그럼 에러는 어떨까, observer가 onError를 통해 맨 처음 만들어줬던 에러 중 single 에러를 내뱉도록 했다.

실행시키면 우리가 만들었던 0번째 에러를 내고 종료한다.

싱글같은 경우 네트워크 환경에서도 많이 사용된다.

JSON을 주고 받는 환경에서 성공을 했느냐 아니면 실패했느냐

이 두 가지 경우밖에 없기 때문에 이 경우를 가정하고 많이 사용된다.

예를 들어서 3번째 싱글 예제로 살펴보자.

```swift
 /*
 실행 결과
 --------Single3---------
 yong
 */
print("--------Single3---------")
struct SomeJSON: Decodable {
    let name: String
}

enum JSONError: Error {
    case decodingError
}

let json1 = """
  {"name":"yong"}
"""

let json2 = """
{"my_name:"jin"}
"""

func decode(json: String) -> Single<SomeJSON> {
    Single<SomeJSON>.create { observer -> Disposable in
        guard let data = json.data(using: .utf8),
              let json = try? JSONDecoder().decode(SomeJSON.self, from: data) else {
            //실패시
            observer(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        //문제 없이 성공
        observer(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
        switch $0 {
        case .success(let json):
            print(json.name)
        case .failure(let error):
            print(error)
        }
    }
    .disposed(by: disposeBag)
```

JSON 객체인 json1을 만들어주고, 이녀석을 decode할 모델인 SomeJSON을 만들어준다.

Json 디코드 과정에서 실패시 발생할 에러 JSONError를 enum으로 만들어주고

json 객체를 받아 Single<SomeJSON>로 반환해주는 decode 함수를 만들어준다.

예전에 우리가 했던 JSON 디코드 방식과 거의 유사하다.

JSONDecoder를 이용해서 디코드 해주고, 실패 시 observer(.failure(JSONError.decodingError))

위에서 만들어줬던 에러를 observer에 준다.

만들어준 디코드 함수에 json1 객체를 넣어서, switch 문을 이용해 성공이냐 실패냐를 보면

json.name의 이름이 정상적으로 찍히는 것을 알 수 있다.

Maybe는 싱글과 비슷하지만 단지 아무것도 내뱉지 않는 completed가 있는 것만 다르다고 했다.

구독의 인자에도 당연히 변화가 생겼다. 

<img width="316" alt="스크린샷 2024-01-30 오후 2 29 45" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/dea6c63a-aece-4438-bbb7-6b7311f90cc0">

```swift
 /*
 실행 결과
 --------Maybe1---------
 ✅
 disposed
 */
print("--------Maybe1---------")
Maybe<String>.just("✅")
    .subscribe(
        onSuccess: {
            print($0)
        },
        onError: {
            print($0)
        },
        onCompleted: {
            print("Completed")
        },
        onDisposed: {
            print("disposed")
        }
    )
    .disposed(by: disposeBag)
```

```swift
/*
 실행 결과
 --------Maybe2---------
 에러: maybe
 disposed
 */
print("--------Maybe2---------")
Observable<String>.create { observer -> Disposable in
    observer.onError(TraitsError.maybe)
    return Disposables.create()
}
.asMaybe()
.subscribe(
    onSuccess: {
        print("성공: \($0)")
    },
    onError: {
        print("에러: \($0)")
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)
```

마지막으로 completable을 살펴보자.

이녀석은 분명 as를 사용해서 전환할 수 없다고 했다.

```swift
/*
 실행 결과
 ------------Completable1-------------
 error: completable
 disposed
 */
print("------------Completable1-------------")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
.subscribe(
    onCompleted: {
        print("completed")
    },
    onError: {
        print("error: \($0)")
    },
    onDisposed: {
        print("disposed")
    }
)
.disposed(by: disposeBag)
```

</details>

<details>
  <summary><b>Subject 알아보기</b></summary>
  지금까지 Observable을 통해서 배운건 Observable이 무엇인지, 어떻게 만들고 구독하고 dispose 하는 지였다. **하지만 보통의 앱 개발에서 필요한 건 실시간으로 Observable의 새로운 값을 수동으로 추가하고 subscriber에게 방출하도록 하는 것이다**. 즉  Observable이자 Observer인 녀석이 필요하다.

이것을 우리는 Subject라고 부른다. 

Subject에는 3가지 종류가 있다.

- PublishSubject
    - 빈 상태로 시작하여 새로운 값만을 subscriber에 방출한다.
- BehaviorSubject
    - 하나의 초기값을 가진 상태로 시작하여, 새로운 subscriber에게 초기값 또는 최신값을 방출한다.
- ReplaySubject
    - 버퍼를 두고 초기화하며, 버퍼 사이즈 만큼의 값들을 유지하면서 새로운 subscriber에게 방출한다.

좀 더 이해하기 쉽도록 marble diagram을 이용해 확인해보자.

- PublishSubject

![Untitled (Draft)-4 3](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/8654b6da-66f0-4e94-97bc-3c32ea21de4e)

PublishSubject는 구독된 순간 새로운 이벤트 수신을 알리고 싶을 때 용이하다. 

이런 활동은 구독을 멈추거나, 어떤 completed, error 이벤트를 통해서 subject가 완전히 종료될때까지 계속된다.

위의 그림에서 첫번째 줄은 subject를 만들어서 배포를 하는 것이다.

그럼 이 서브젝트를 바라보고 있는 두 번째와 세 번째가 subscriber일텐데 

아래로 향하는 화살표는 이벤트를 방출하는 것을 의미하고

위로 향하는 화살표는 구독을 선언하는 것을 의미한다.

두 번째 서브젝트는 1이라는 이벤트가 방출된 다음부터 구독을 했기 때문에 1이벤트는 받지 못하고 구독한 이후에 처음으로 발생한 2, 3을 받을 수 있을 것이다.

세 번째 서브젝트는 1,2라는 이벤트를 방출한 다음에 구독을 시작했기 때문에 

앞서 지나간 이벤트들은 받지 못한다. 그 후에 발생한 이벤트 중 최신값인 3을 갖게 되는 것이다.

- BehaviorSubject
![Untitled (Draft)-7 2](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/42b3baa9-370b-4414-9b61-cdd66b9a1266)


BehaviorSubject는 마지막 next이벤트를 새로운 구독자에게 반복한다는 점, 이 점만 빼면 PublicSubject와 유사하다.

그림을 보며 이해해보자.

첫번째 줄이 BehaviorSubject이다. 두번째 세번째 줄은 위에서도 보았듯이 구독자들이다.

첫번째 구독자는 1이라는 이벤트가 방출된 다음 구독을 시작했고,

두번째 구독자는 2라는 이벤트가 방출된 다음 구독을 시작했다.

publishSubject와 다른 점은 첫번째 이벤트가 발생한 직후 첫 번째 구독자가 구독을 시작했지만

publishSubject와는 다르게 직전에 값인 1을 받는다.

2 이벤트가 발생한 후 두 번째 구독자가 구독을 시작했으나, 역시나 2번째 값인 2를 받을 수 있다.

 

- ReplaySubject
![Untitled (Draft)-8 2](https://github.com/jinyongyun/Github_repo_APP/assets/102133961/46bdd407-44a8-4691-baa5-163912442e80)


마지막으로 ReplaySubject

ReplaySubject는 이 서브젝트를 생성할 때, 선택한 특정 크기까지 방출하는 최신 요소를 일시적으로 캐싱을 하거나 버퍼로 둔다. 이렇게 잘 보관해둔 것들을 구독자가 생길때마다 방출한다.

그림을 보면 역시 첫번째 줄이 ReplaySubject이고 아래에 있는 아이들은 구독자들이다.

버퍼 사이즈를 2라고 두면, 첫번째 구독자는 Subject와 함께 구독하기 때문에 그대로 다 받는다.

즉 이 서브젝트가 발생한 시점부터 바로 구독하고 있기 떄문에 그대로 받는다.

하지만 두 번째 구독자는 2를 보낸 다음부터 구독을 시작했다.

이때 버퍼 사이즈가 2이기 때문에 그 크기 만큼의 값 (1,2)을 역시 받을 수 있다.

뒤늦게 구독을 했음에도 1,2 값을 전부 받은 다음, 3도 받을 수 있다.

이때 유념해야 할 점이 있다.

내가 설정한 몇 개의 버퍼를 가져라-의 버퍼들은 메모리가 갖고 있다.

그래서 이 버퍼를 많이 쓰면 메모리에 엄청난 부하를 줄 것이다.

이번에도 subject를 코드를 직접 작성하며 연습해보도록 하자.

```swift
import RxSwift

let disposeBag  = DisposeBag()

/*
 실행 결과
 ------publishSubject------
 2.들리세요?
 3.정신차리세요!
 4.여보세요 거기 누구 없소
 */
print("------publishSubject------")
let publishSubject = PublishSubject<String>() //이렇게 만든다.
//pulishSubject는 Observable인 동시에 Observer -> Observer의 특성 : 이벤트를 내뱉을 수 있다.
publishSubject.onNext("1.여러분 안녕 내가 누군지 아니?")

// Observable의 특징 : 구독을 해야 의미가 있다.
let 구독자1 = publishSubject
    .subscribe(onNext: {
       print($0)
    })

publishSubject.onNext("2.들리세요?")
publishSubject.on(.next("3.정신차리세요!"))

구독자1.dispose() //수동 dispose

// subject 만들어지고, 이벤트 하나 발생 -> 이후 구독자 생성 -> 이벤트 2개 생성

let 구독자2 = publishSubject
    .subscribe(onNext: { //얘는 3가지 이벤트 전부 방출 후에 구독
        print($0)
    })

publishSubject.onNext("4.여보세요 거기 누구 없소")
publishSubject.onCompleted()

publishSubject.onNext("5.혹시 끝났나요?")

구독자2.dispose() //수동 dispose
```

코드를 보면 구독자1, 구독자2 모두 publishSubject이기 때문에 

자신들이 구독하기 전에 발생한 이벤트는 전혀 받아들이지 못하고 있다.

그래서 구독자1은 이벤트1은 놓치고, 2,3번 이벤트를 받은 다음 disposed되고

구독자2는 4 이벤트를 받고, completed 이벤트도 받아서 종료

다음은 BehaviorSubject를 코드로 살펴보자.

```swift
/*
 실행 결과
 -------behaviorSubject--------
 첫번째구독: 1.첫번째값!
 첫번째구독: error(error1)
 두번째구독: error(error1)
 */
print("-------behaviorSubject--------")
enum SubjectError: Error {
    case error1
}

//behaviorSubject는 반드시 초기값을 가진다.
let behaviorSubject = BehaviorSubject<String>(value: "0. 초기값")

behaviorSubject.onNext("1.첫번째값!")

behaviorSubject.subscribe {
    print("첫번째구독:", $0.element ?? $0)
}
.disposed(by: disposeBag)

behaviorSubject.onError(SubjectError.error1)

behaviorSubject.subscribe {
    print("두번째구독:", $0.element ?? $0)
}
.disposed(by: disposeBag)
```

1번 이벤트가 나타난 이후에 구독을 시작했음에도 결과값에 1번 이벤트가 나타나는 것을 알 수 있다.

다만 직전 값만 받을 수 있어 0번 초기값은 받질 못하고 있다.

두번째 구독자도 자신이 구독하기 직전 이벤트인 에러 이벤트를 무사히 받은 걸 볼 수 있다.

BehaviorSubject의 특징 중 하나가 바로 value 값을 뽑아낼 수 있다는 것이다.

```swift
Observable.of(1)
    .subscribe(onNext: {
       // $0
    })
```

만약 이렇게 Observable에 1이라는 이벤트를 등록하고 구독한다고 하면

해당 클로저 내부에서만 값에 접근할 수 있을텐데…그렇다면 바깥에서 이 값에 접근하려면 어떻게 해야 할까?

이를 위해 존재하는 것이 바로 behaviorSubject의 value이다. value는 try구문으로 뽑을 수 있다.

```swift
 let value = try? behaviorSubject.value()
print(value)
```

마지막으로 ReplaySubject를 코드로 작성해보자.

```swift
/*
 -------ReplaySubject--------
 첫번째구독: 2. 화이팅!!
 첫번째구독: 3. 어렵지만...
 두번째구독: 2. 화이팅!!
 두번째구독: 3. 어렵지만...
 첫번째구독: 4. 우리는 언제나 길을 찾아 낼 겁니다.
 두번째구독: 4. 우리는 언제나 길을 찾아 낼 겁니다.
 첫번째구독: error(error1)
 두번째구독: error(error1)
 세번째구독: error(Object `RxSwift.(unknown context at $1189aa7f4).ReplayMany<Swift.String>` was already disposed.)
 */

print("-------ReplaySubject--------")
let replaySubject = ReplaySubject<String>.create(bufferSize: 2)

replaySubject.onNext("1. 여러분")
replaySubject.onNext("2. 화이팅!!")
replaySubject.onNext("3. 어렵지만...")

replaySubject.subscribe {
    print("첫번째구독:", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject.subscribe {
    print("두번째구독:", $0.element ?? $0)
}
.disposed(by: disposeBag)

replaySubject.onNext("4. 우리는 언제나 길을 찾아 낼 겁니다.")
replaySubject.onError(SubjectError.error1)
replaySubject.dispose()

replaySubject.subscribe {
    print("세번째구독:", $0.element ?? $0)
}
.disposed(by: disposeBag)
```

서브젝트를 정의한 다음, 이벤트 3개를 만들고 → 첫번째 구독자 등장 → 두번째 구독자 등장 → 4번째 이벤트 등장 → 에러 이벤트 →수동 dispose → 세 번째 구독자 등장

첫번째 구독자는 세가지 이벤트 방출 뒤에 구독을 시작했으나 replaySubject의 버퍼에서 최근 2가지 이벤트 값을 받아올 수 있었다. 이는 두번째 구독자도 마찬가지

4번째 이벤트는 구독 다음이니 당연히 잘 받을테고

에러도 마찬가지

하지만 3번째 구독자는 이미 Observable이 dispose 된 상태에서 구독을 하니 RxSwift에서 에러를 보낸 것이다.
</details>


<details>
  <summary><b>Filtering Operator</b></summary>
  Observable에 대한 내용은 위에서 알아봤고, 이제 오퍼레이터에 대한 내용을 알아보자.

그 중에서도 이번에 배울 건, Filtering Operator라고 해서 

nextEvent를 통해 받아오는 값을 선택적으로 취할 수 있게 해주는 연산자이다.

기존 swift에서 filter 메서드와 유사한 역할을 한다.

- ignoreElements

```swift
import RxSwift

let disposeBag = DisposeBag()

/*
 onNext로 일어나는 이벤트 전부 무시!
 
 실행결과
 --------ignoreElements---------
 ☀️
 */
print("--------ignoreElements---------")

let 취침모드 = PublishSubject<String>()

취침모드
    .ignoreElements()
    .subscribe { _ in
        print("☀️")
    }
    .disposed(by: disposeBag)

취침모드.onNext("🔊")
취침모드.onNext("🔊")
취침모드.onNext("🔊")

취침모드.onCompleted()
```

첫번째로 배울 Filtering Operator는 ignoreElements이다. 이녀석은 onNext로 발생하는 이벤트를 모조리 무시해버린다. 위의 코드를 보면 이벤트가 발생할 때마다 해가 찍히도록 했는데,

실행결과를 보면 onCompleted 이벤트에서만 해가 찍힌 것을 보면 이녀석이 onNext를 무시한다는 것을 명확히 알 수 있다.

- elementAt

```swift
/*
at에 들어가는 idx번째 이벤트의 값에 대해서만 방출
실행결과
 --------elementAt---------
 🐽
*/
print("--------elementAt---------")

let 두번울면깨는사람 = PublishSubject<String>()

두번울면깨는사람
    .element(at: 2)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

두번울면깨는사람.onNext("🔊")
두번울면깨는사람.onNext("🔊")
두번울면깨는사람.onNext("🐽")
두번울면깨는사람.onNext("🔊")
```

- filter

```swift
/*
filter에 해당하는 값만 방출
실행결과
 --------filter---------
 2
 4
 6
 8
*/
print("--------filter---------")
Observable.of(1,2,3,4,5,6,7,8)
    .filter { $0 % 2 == 0 }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
```

- skip && skipWhile

```swift
/*
몇 개를 무시할건지 지정
실행결과
 --------skip---------
 👀
*/
print("--------skip---------")
Observable.of("😀", "😃", "😘", "😜", "😇", "👀")
    .skip(5)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
어떤 요소를 스킵하지 않을 때까지 스킵하고 종료
스킵할 로직 구현 후, 해당 로직이 false가 되면 방출
실행결과
--------skipWhile---------
👀
😘
😜
*/
print("--------skipWhile---------")
Observable.of("😀", "😃", "😘", "😜", "😇", "👀", "😘", "😜")
    .skip(while: {
        $0 != "👀"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 다른 Observable이 시동할때까지 현재 Observable에서 방출하는 모든 이벤트 무시
 실행 결과
 ---------skipUntil-----------
 😇
 */
print("---------skipUntil-----------")
let 손님 = PublishSubject<String>()
let 문여는시간 = PublishSubject<String>()

손님
    .skip(until: 문여는시간)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

손님.onNext("😀")
손님.onNext("😃")

문여는시간.onNext("땡!")

손님.onNext("😇")
```

- take

```swift
/*
 taking은 skipping의 반대 개념 -> RxSwift에서 어떤 요소를 취하고 싶을 때 사용
 take에다 취하길 원하는 요소 개수 넣어!
 실행 결과
 ---------take-----------
 🥇
 🥈
 🥉
*/
print("---------take-----------")
Observable.of("🥇", "🥈", "🥉", "🏅", "🎖️")
    .take(3)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
skipWhile과 완전히 반대로 작용
 take안에 구문이 false가 되면 구독 던짐
 실행 결과
 ---------takeWhile-----------
 🥇
 🥈
*/
print("---------takeWhile-----------")
Observable.of("🥇", "🥈", "🥉", "🏅", "🎖️")
    .take(while: {
        $0 != "🥉"
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
트리거가 되는 Observable이 구독되기 전까지의 값만 받기
 실행 결과
 ---------takeUntil-----------
 🙋🏻‍♂️
 🙋🏻
*/
print("---------takeUntil-----------")

let 수강신청 = PublishSubject<String>()
let 신청마감 = PublishSubject<String>()

수강신청
    .take(until: 신청마감)
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

수강신청.onNext("🙋🏻‍♂️")
수강신청.onNext("🙋🏻")

신청마감.onNext("끝!")

수강신청.onNext("🙋‍♀️")
```

- enumerated

```swift
/*
 방출된 요소의 인덱스를 참고하고 싶을 때
 실행 결과
 --------enumerated---------
 (index: 0, element: "🥇")
 (index: 1, element: "🥈")
 (index: 2, element: "🥉")
*/
print("--------enumerated---------")
Observable.of("🥇", "🥈", "🥉", "🏅", "🎖️")
    .enumerated()
    .take(while: {
        $0.index < 3
    })
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
```

- distinctUntilChanged

```swift
/*
 연달아 같은 값이 이어질 때 동일한 값을 제거
 실행 결과
 ---------distinctUntilChanged-----------
 저는
 앵무새
 바보
 앵무새
 입니다
 저는
*/
print("---------distinctUntilChanged-----------")
Observable.of("저는", "앵무새", "앵무새", "앵무새", "앵무새", "바보", "앵무새", "앵무새", "앵무새", "앵무새", "입니다", "입니다", "입니다", "저는")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
```
</details>

<details>
  <summary><b>Transforming Operator</b></summary>
  이번에는 RxSwift 오퍼레이터 중에서 가장 중요하다고 평가받는 Transforming Operator에 대해 배워보자.

변환 연산자는 subscriber를 통해서 Observable에서 데이터를 준비하는 것 같은 모든 상황에서 쓰일 수 있다. 

앞서 배운 Filter처럼 여기서도 map이나 flatmap과 같이 기본 swift 표준 라이브러리와 유사점이 있는 연산자들을 확인할 수 있다.

- **toArray**

```swift
 import RxSwift

let disposeBag = DisposeBag()

print("---------toArray----------")
Observable.of("A", "B", "C")
    .toArray()
    .subscribe(onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)

/*
 실행결과
 ---------toArray----------
 ["A", "B", "C"]
 */
```

첫번째는 toArray 말 그대로 Observable.of를 통해 받은 녀석들을 한 배열로 묶어주는 녀석이다.

- map

RxSwift에서의 map은 Observable에서 동작한다는 점만 빼면 swift에서의 map과 똑같다.

```swift
print("---------map----------")
Observable.of(Date())
    .map { date -> String in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        return dateFormatter.string(from: date)
    }
    .subscribe(onNext: {
        print($0)
    })

/*
 실행결과
 ---------map----------
 2024-02-16
 */
```

Observable에서 현재 날짜를 뱉어주도록 했다. 현재 날짜에 맞게 형식을 지정해서 String으로 리턴해주도록 map을 해줬다.

- flatMap

Observable 속성을 갖는 Observable은 어떻게 사용할 수 있을까?

라는 생각을 해본 적 있는가

이런 생각을 대체 왜 하니…라고 할 수도 있지만, 필자는 어쨌든 해봤다.

Observable<Observable<String>> 이렇게 중첩된 Observable이면 우리는 어떻게 해야할까?

Observable을 일종의 배열로 단순화 한다면 [[String]] 이런 형태일 것이다.

이럴 경우에는 어떻게 할 수 있을까?

예시를 들어보겠다.

```swift
print("---------flatMap----------")
protocol 선수 {
    var 점수: BehaviorSubject<Int> { get }
}

struct 양궁선수: 선수 {
    var 점수 : BehaviorSubject<Int>
}

let 한국국대 = 양궁선수(점수: BehaviorSubject<Int>(value: 10))
let 미국국대 = 양궁선수(점수: BehaviorSubject<Int>(value: 8))

//이미 BehaviorSubject를 갖는 선수 프로토콜을 준수, 즉 Observable이자 Observer의 역할인 Subject가 이중으로!
let 올림픽경기 = PublishSubject<선수>()

//이렇게 중첩된 Observable에서 특정한 선수가 가진 점수를 얻거나, 그것을 핸들링 할 때 flatMap을 사용할 수 있다.

올림픽경기
    .flatMap { 선수 in
        선수.점수
    }.subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

올림픽경기.onNext(한국국대)
한국국대.점수.onNext(10)

올림픽경기.onNext(미국국대)
한국국대.점수.onNext(10)
미국국대.점수.onNext(9)
/*
 실행결과
 ---------flatMap----------
 10
 10
 8
 10
 9
 */
```

양궁 올림픽 경기로 예시를 들어봤다.

결과를 보면 BehaviorSubject의 특성상 초기값이 나오고(구독시작에서)

그 다음 한국국가대표가 점수를 획득하자 10이 찍혔다.

미국국대를 구독하니까 초기값 8

다시 한국 선수의 이벤트 발생으로 10

미국국대의 이벤트 발생으로 9가 차례로 나온 것이다.

중요한 것은 flatMap을 통해 중첩된 Subject 즉 Observable의 엘레멘트를 가져왔단 사실이다!

- flatMapLatest

```swift
print("---------flatMapLatest----------")

struct 높이뛰기선수: 선수 {
    var 점수 : BehaviorSubject<Int>
}

let 대전 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 7))
let 제주 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 6))

let 전국체전 = PublishSubject<선수>()

전국체전
    .flatMapLatest { 선수 in
        선수.점수
    }
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

전국체전.onNext(대전)
대전.점수.onNext(9)

전국체전.onNext(제주)
대전.점수.onNext(10)
제주.점수.onNext(8)

/*
 실행결과
 ---------flatMapLatest----------
 7
 9
 6
 8
 */
```

flatMapLatest는 표현에서 알 수 있듯이 Latest 즉 가장 최신의 값만을 확인하고 싶을 때 사용한다.

전국체전이라는 시퀀스가 갖고 있는 선수의 점수라는 시퀀스가 있다.

처음 전국체전이 대전을 구독했을 때, 가장 최신 값은 대전 초기값인 7이었다.

따라서 7을 내뱉고, 그 다음 대전 onNext에 의해 9를 내뱉었다.

제주도 마찬가지로 OnNext에 의해 가장 최신값인 초기값을 내뱉은 것이다.

그리고 이제 대전 선수가 10을 뱉었는데, 이건 최신의 값인 9에 의해서 10의 값이 버려진다.

전국체전 입장에서는 대전 선수의 시퀀스, 제주 선수의 시퀀스 이 두가지 시퀀스가 있다.

전국체전이 대전만을 갖고 있을 때는 계속해서 새로운 값을 뱉어도 이 대전 시퀀스가 최신이기 때문에 계속 업데이트가 된다. 하지만 제주라는 새로운 시퀀스가 발생한 이후부터는 대전은 아무리 점수를 내도 받아들여지지 않는다.

예를 들어 우리가 영어사전을 검색할 때 알파벳이 추가됨에 따라, 새로운 String에 맞는 검색결과가 나온다.

이럴 때, flatMapLatest가 활용된다. 이전 스트링 시퀀스는 무시하고 새로운 스트링을 기반으로 자동 검색을 하는 것이다.

- materialize & dematerialize

Observable을 Observable의 이벤트로 변환해야 할 때가 있다.

보통 Observable 속성을 가진 Observable 항목을 제어할 수 없고 외부적으로 Observable이 종료되는 것을 방지하기 위해 에러 이벤트를 처리하고 싶을 때가 있을 것이다.

이게 무슨 말이지…? 싶은 분들을 위해 아래 예제를 준비했다.

```swift
print("----------materialize and dematerialize------------")
enum 반칙: Error {
    case 부정출발
}

struct 육상선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 윤토끼 = 육상선수(점수: BehaviorSubject<Int>(value: 0))
let 윤거북 = 육상선수(점수: BehaviorSubject<Int>(value: 1))

let 육상100M = BehaviorSubject<선수>(value: 윤토끼)

육상100M
    .flatMapLatest { 선수 in
        선수.점수
            .materialize()
    }
    .filter {
        guard let error = $0.error else {
            return true
        }
        print(error)
        return false
    }
    .dematerialize()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)

윤토끼.점수.onNext(1)
윤토끼.점수.onError(반칙.부정출발)
윤토끼.점수.onNext(2)

육상100M.onNext(윤거북)

/*
 
 실행결과: materialize 제외
 ----------materialize and dematerialize------------
 0
 1
 Unhandled error happened: 부정출발
 
 실행결과 : materialize 추가
 ----------materialize and dematerialize------------
 next(0)
 next(1)
 error(부정출발)
 next(1)
 
 실행결과 : dematerialize 추가
 ----------materialize and dematerialize------------
 0
 1
 부정출발
 1
 */
```

여기서 중요한 점은 flatMapLatest를 통해 반칙이라는 새로운 시퀀스 발생으로 무시되는 윤토끼의 2 아웃풋도 있지만, materialize와 dematerialize의 역할이다.

materialize는 이벤트에 감싸서 materialize의 역할을 볼 수 있다.

단순히 선수의 점수만을 주는 것이 아니라, 이벤트들을  함께 받을 수 있다.

dematerialize는 다시 원래 상태로 돌려주는 것!
</details>

<details>
  <summary><b>GitHub 앱 만들기 과정</b></summary>
  이미 [RxSwift 설치하기] 과정에서 GitHubRepository 파일을 만들었다.

이 swift 파일을 기반으로 진행한다.

여기에는 이미 pod 파일을 통해 RxCocoa도 깔려 있다.

먼저 RootViewController 부터 만들기 전에…ViewController.swift와 Main.storyboard를 사용하지 않을 예정이라 지워준다.

**info.plist에서도 Main 관련 내용 지워주는 거 잊지 말기!!**

<img width="973" alt="스크린샷 2024-03-27 오후 10 51 52" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/8df371b1-5452-4e30-ad35-86bed5245176">

그리고 SceneDelegate로 가서 RootViewController를 지정해줘야 한다. 

그러기 위해 RootViewController 역할을 할 RepositoryListViewController를 만들어준다.

```swift
//  RepositoryListViewController.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/27/24.
//

import UIKit

class RepositoryListViewController: **UITableViewController** {
    
    
}

```

SceneDelegate로 이동해서 rootNavigationController로 RepositoryListViewController를 감싸서

rootViewController로 지정한 뒤, makeKeyAndVisible()를 실행해준다.

지금까지 상당히 많이 봤던 코드라 쉽게 이해할 수 있을 것이다.

```swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else {return}
        self.window = UIWindow(windowScene: windowScene)
        
        let rootViewController = RepositoryListViewController()
        let rootNavigationController = UINavigationController(rootViewController: rootViewController)
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
        
    }
```

깃헙 레포지토리를 구현할 커스텀 셀을 만들어주기 위해, RepositoryListCell 파일을 만들어준다.

cell UI를 SnapKit을 통해서 만들어 줄 예정이라

File > Add Package Dependency

SnapKit을 추가하고

셀을 만들어준다.

```swift
//
//  RepositoryListCell.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/27/24.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    var repository: String? //GitHub API에서 가져올 레포
    
    let nameLabel = UILabel() //repository 이름
    let descriptionLabel = UILabel() //어떤 repo인지 설명
    let starImageView = UIImageView() // 스타 표시 이미지
    let starLabel = UILabel() //얼마나 많은 스타를 받았는지
    let languageLabel = UILabel() // 어떤 언어를 사용했는지
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
           nameLabel, descriptionLabel,
           starImageView, starLabel, languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        //각 라벨의 폰트 등은 깃헙 레포에서 가져오고 난 뒤에 설정!
    }
    
}

```

셀을 만든 뒤에는, RepositoryListViewController에 셀을 등록시켜야 한다.

```swift
//  RepositoryListViewController.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/27/24.
//

import UIKit

class RepositoryListViewController: UITableViewController {
    private let organization = "Apple" //애플 공식 깃헙 계정에 있는 레포 가져올래
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = organization + "Repositories"
        
        self.refreshControl = UIRefreshControl() //당겨서 새로고침하는 역할 -> 이녀석 당겼을 때 API 호출
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
        
    }
    
    @objc func refresh() {
        // API networking 관련 내용
    }
    
}

//UITableView DataSource Delegate
extension RepositoryListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for: indexPath) as? RepositoryListCell else {return UITableViewCell()}
        
        return cell
    }
    
}

```

일단 UI 관련 로직은 이게 전부이다!

상당히 간단!!

다음은 Github API를 연결해보자.

[GitHub REST API documentation - GitHub Docs](https://docs.github.com/en/rest?apiVersion=2022-11-28)

다음의 url로 들어가면, github에서 제공해주는 github docs로 이동한다.

여기 Reference에서 List organization repositories를 선택해 들어간다.

[REST API endpoints for repositories - GitHub Docs](https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28)

어떤 형태로 연결을 해야 하는지

정상적으로 Response를 받았다면 어떤 형태로 오는지 적혀있으니, 살펴보도록 하자

<img width="1286" alt="스크린샷 2024-03-28 오후 1 58 00" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/0e3b3448-4b7c-47fb-a8d2-e4c9a9d347cd">

한 번 이 docs에 적힌 대로, postman에서 연결해보자.
<img width="220" alt="스크린샷 2024-03-28 오후 1 59 53" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/df6d65f7-48ba-4212-9d30-94eda484444b">


다음의 형태로 특정 organization의 레포지토리에 접근하라고 되어 있기 때문에

organization을 애플로 해서, 애플 레포지토리를 띄워보겠다.

> https://api.github.com/orgs/apple/repos
> 

이렇게 url을 작성한 다음, send를 누르면
<img width="1216" alt="스크린샷 2024-03-28 오후 2 03 09" src="https://github.com/jinyongyun/Github_repo_APP/assets/102133961/00d1d541-66ca-4416-8b50-71a55887d5b1">


다음과 같이 json 데이터가 넘어오는 것을 알 수 있다.

물론 이 모든 정보를 사용하지는 않을 것이다.

따라서 repository에 필요한 정보만 모아 놓기 위한 엔티티를 하나 만든다.

미리 만들어놓은 RepositoryListCell과 우리가 위에서 받아온 Json의 내용을 비교해서 

뭘 가져올 지를 선택해야한다.

우선 RepositoryListCell에 지정해둔 대로, 

name, description, stargazes_url, stargazers_count, language를 각각 가져오면 된다.

```swift
//  Repository.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/28/24.
//

import Foundation

struct Repository: Decodable {
    let id: Int
    let name: String
    let description: String
    let stargazersCount: Int
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, language
        case stargazersCount = "stargazers_count"
    }
}

```

이제 이걸 셀에다 표현하면 된다.

```swift
//
//  RepositoryListCell.swift
//  GitHubRepository
//
//  Created by jinyong yun on 3/27/24.
//

import UIKit
import SnapKit

class RepositoryListCell: UITableViewCell {
    var repository: Repository? //GitHub API에서 가져올 레포
    
    let nameLabel = UILabel() //repository 이름
    let descriptionLabel = UILabel() //어떤 repo인지 설명
    let starImageView = UIImageView() // 스타 표시 이미지
    let starLabel = UILabel() //얼마나 많은 스타를 받았는지
    let languageLabel = UILabel() // 어떤 언어를 사용했는지
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [
           nameLabel, descriptionLabel,
           starImageView, starLabel, languageLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        guard let repository = repository else {return}
        nameLabel.text = repository.name
        nameLabel.font = .systemFont(ofSize: 15, weight: .bold)
        
        descriptionLabel.text = repository.description
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 2
        
        starImageView.image = UIImage(systemName: "star")
        
        starLabel.text = "\(repository.stargazersCount)"
        starLabel.font = .systemFont(ofSize: 16)
        starLabel.textColor = .gray
        
        languageLabel.text = repository.language
        languageLabel.font = .systemFont(ofSize: 16)
        languageLabel.textColor = .gray
       
       
       //여기서부터는 내뇌 지도에 의한 makeConstraints
        nameLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(18)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
            $0.leading.trailing.equalTo(nameLabel)
        }
        
        starImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(8)
            $0.leading.equalTo(descriptionLabel)
            $0.width.height.equalTo(20)
            $0.bottom.equalToSuperview().inset(18)
        }
        
        starLabel.snp.makeConstraints {
            $0.centerY.equalTo(starImageView)
            $0.leading.equalTo(starImageView.snp.trailing).offset(5)
        }
        
        languageLabel.snp.makeConstraints {
            $0.centerY.equalTo(starLabel)
            $0.leading.equalTo(starLabel.snp.trailing).offset(12)
        }
        
        
    }
    
}

```

드디어 RxSwift를 이용해서 API를 연결해 볼 차례이다!

RepositoryListViewController로 돌아가서

RxSwift와 RxCocoa를 import 해준다.

원래라면

private let repositories = [Repository]

이런 식으로 repositories배열에다 API로 담아온 데이터를 넣었겠지만,

이제는 다르다!

**private** **let** repositories = BehaviorSubject<[Repository]>(value: [])

BehaviorSubject를 선언하고, [Repository]을 한 element로 담을 수 있게 선언한다.

BehaviorSubject는 초기값을 줘야만 하니,

빈 배열을 초기값으로 지정해줬다.

그 밑에는 disposeBag도 미리미리 선언해주자.

다음으로 만들 것은 API를 통해 직접 json을 fetching 하기 위한 fetching 함수이다.

최대한 위에서 배운 것들을 습득할 수 있도록 풀어서 작성했다.

```swift
 func fetchRepositories(of organization: String){
        Observable.from([organization])
            .map { organization -> URL in //Apple String 주어지면 URL로 변환!
                return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
            }
            .map { url -> URLRequest in //이번에는 url타입 받아서 URLRequest로!
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                return request
            } //request를 HTTPURLResponse와 Data 이 두개를 튜플의 형태로 갖는 Observable로 전달!
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                return URLSession.shared.rx.response(request: request)
            }
            .filter { response, _ in
                return 200..<300 ~= response.statusCode
            }
            .map { _, data -> [[String: Any]] in
                guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                      let result = json as? [[String: Any]] else {
                    return []
                }
                return result
            }
            .filter { result in  //빈 array이면 안받음!
                result.count > 0
            }
            .map { objects in
                return objects.compactMap { dic -> Repository? in
                    guard let id = dic["id"] as? Int,
                          let name = dic["name"] as? String,
                          let description = dic["description"] as? String,
                          let stargazersCount = dic["stargazers_count"] as? Int,
                          let language = dic["language"] as? String else {
                        return nil
                    }
                    
                    return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
                }
            }
            .subscribe(onNext: { [weak self] newRepositories in
                self?.repositories.onNext(newRepositories)
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
            })
            .disposed(by: disposeBag)
    }
    
```

풀어쓰느라 코드가 길긴 긴데 그다지 어려운 내용은 아니다.

간추려서 말하면, subscribe 할 때 onNext 이외에도 뒤에 여러 파라미터가 나오지 않는가

에러라든지 

이런 것들을 map과 filter 그리고 flatMap을 통해 하나씩 제거하고

마지막에 우리가 선언해 둔 BehaviorSubject인 repositories에 onNext로 넘겨주는 것이다.

그럼 나중에 이 repositories를 구독해서 읽을 수 있겠지!

fetchRepositories를 이전에 선언해 둔 refresh 함수에다 넣어주면 끝!

```swift
 @objc func refresh() {
        // API networking 관련 내용
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        }
    }
```

이렇게 하면 fetching 자체는 잘 동작할 것이다.

하지만 아직 uI에 뿌려주는 코드는 작성하지 않았다.

위에서 말한 BehaviorSubject의 독특한 특징이 있었다.

기억나는가?

바로 value 값을 뽑아낼 수 있다는 것이었다.

numberOfRowsInSection을 이 value값을 count 내어 리턴해줄 수 있다.

```swift

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try repositories.value().count
        } catch {
            return 0
        }
        
    }
```

 그렇다면 cellForRowAt은 어떻게 작성할 수 있을까?

이녀석도 마찬가지로 value을 활용할 수 있다.

```swift
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for: indexPath) as? RepositoryListCell else {return UITableViewCell()}
        
        var currentRepo: Repository? {
            do { //잘 가져왔다면 BehaviorSubject의 value 중에서도 indexPath.row에 있는 녀석
                return try repositories.value()[indexPath.row]
            } catch {
                return nil //에러 나면 어떠한 레포도 없다.
            }
        }
        
        cell.repository = currentRepo
        
        return cell
    }
```

</details>

# 실제 앱 구동 화면


https://github.com/jinyongyun/Github_repo_APP/assets/102133961/d6e61048-fbbe-4991-9840-8d61a543ff1d


