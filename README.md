# swipe_select_grid_view

A grid view that supports both swipe and tapping to select its items like ios Photos .  

<video width="208" height="463" controls>
  <source src="demo.mp4" type="video/mp4">
</video>

## Getting Started

#### Setup

```yaml
dependencies:
  swipe_select_grid_view: 0.0.1
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