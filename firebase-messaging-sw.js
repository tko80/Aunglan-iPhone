importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDhUAq9hqVtz3hKl-xmbWR3DZITGAtZgME",
  authDomain: "aunglan-2fae0.firebaseapp.com",
  projectId: "aunglan-2fae0",
  storageBucket: "aunglan-2fae0.firebasestorage.app",
  messagingSenderId: "1013010215516",
  appId: "1:1013010215516:web:ccf9df38eee7319ca1ac99",
  measurementId: "G-7WYBDSSVDD"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = (payload.notification && payload.notification.title) || "Aunglan Update";
  const options = {
    body: (payload.notification && payload.notification.body) || "A new announcement is available.",
    icon: "./icon.png",
    badge: "./icon.png",
    data: { url: "./" }
  };
  self.registration.showNotification(title, options);
});

self.addEventListener("notificationclick", (event) => {
  event.notification.close();
  event.waitUntil((async () => {
    const url = new URL("./", self.location.href).href;
    const clientsList = await clients.matchAll({ type: "window", includeUncontrolled: true });
    for (const client of clientsList) {
      if (client.url.startsWith(self.location.origin) && "focus" in client) {
        await client.focus();
        return;
      }
    }
    if (clients.openWindow) await clients.openWindow(url);
  })());
});
