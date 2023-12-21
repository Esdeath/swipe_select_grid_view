# swipe_select_grid_view

A grid view that supports both swipe and tapping to select its items like ios Photos .  

[](demo.png)
https://github.com/Esdeath/swipe_select_grid_view/assets/8644245/de63674f-621c-4c0b-8e9d-cba7c181e1b7


## Getting Started

#### Setup

```yaml
dependencies:
  swipe_select_grid_view: 1.1.0
```

Then run `flutter pub get` to download the dependencies.

## Sample

```dart

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Swipe select'),
        ),
        body: SwipeSelectGridView(
          padding: const EdgeInsets.all(10),
          itemCount: 100,
          itemBuilder: (context, index, selected) {
            return Container(
              color: Colors.grey,
              child: Stack(
                children: [
                  Image.asset('images/avatar.png'),
                  Visibility(
                    visible: selected,
                    child: Container(
                      color: const Color(0x66FFFFFF),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Visibility(
                      visible: selected,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: Image.asset(
                            'images/icon_selected.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Visibility(
                      visible: !selected,
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: Center(
                          child: Image.asset(
                            'images/icon_default.png',
                            width: 30,
                            height: 30,
                            fit: BoxFit.fill,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
        ),
      ),
    );
  }
}

```

## License

MIT License
