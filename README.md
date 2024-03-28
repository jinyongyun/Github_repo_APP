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
  <!-- 내용 -->
</details>

<details>
  <summary><b>두번째토글</b></summary>
  <!-- 내용 -->
</details>
