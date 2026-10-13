
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyDhUA9hqVtz3hKl-xmbWR3DZITGAtZgME",
  authDomain: "aunglan-2fae0.firebaseapp.com",
  projectId: "aunglan-2fae0",
  storageBucket: "aunglan-2fae0.firebasestorage.app",
  messagingSenderId: "1013010215516",
  appId: "1:1013010215516:web:ccf9df38eee7319ca1ac99",
  measurementId: "G-7WYBDSSVDD"
});

const messaging = firebase.messaging();

// Avoid manually displaying the same notification twice.
// Firebase handles background notification payloads automatically.

self.addEventListener("notificationclick", (event) => {
  event.notification.close();

  event.waitUntil((async () => {
    const url = new URL("./", self.location.href).href;
    const clientsList = await self.clients.matchAll({
      type: "window",
      includeUncontrolled: true
    });

    for (const client of clientsList) {
      if (client.url.startsWith(self.location.origin)) {
        await client.focus();
        return;
      }
    }

    if (self.clients.openWindow) {
      await self.clients.openWindow(url);
    }
  })());
});
