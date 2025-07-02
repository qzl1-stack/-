#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

// 引入新的头文件
#include "textfilehandler.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    app.setApplicationName("文本分析器");
    app.setApplicationVersion("1.0");

    QQmlApplicationEngine engine;
    
    // 注册文件处理器
    TextFileHandler fileHandler;
    engine.rootContext()->setContextProperty("fileHandler", &fileHandler);
    
    const QUrl url(QStringLiteral("qrc:/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    
    engine.load(url);

    return app.exec();
}

#include "main.moc"
