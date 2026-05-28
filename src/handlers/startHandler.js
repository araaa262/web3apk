const { getMainKeyboard } = require('../utils/keyboard');

/**
 * Handle /start command
 */
async function handleStart(bot, msg) {
    const chatId = msg.chat.id;
    const safeName = (msg.from.first_name || 'User').replace(/</g, '&lt;').replace(/>/g, '&gt;');

    const welcomeCaption = `
👋 <b>Selamat Datang, ${safeName}!</b>

<b>Web2Apk Bot @lindaabeautiful</b>

Bangun APK dari proyek Flutter/Android dengan alur yang rapi, cepat, dan terukur.

<b>Fitur utama</b>
- Antrian otomatis saat slot penuh
- Build dari ZIP atau URL

Silakan pilih menu:
    `.trim();

    await bot.sendPhoto(chatId, 'https://cdnn.ikyyxd.my.id/storage/0edcae5d369caaa957271f4232bd7c57.jpg?preview=true', {
        caption: welcomeCaption,
        parse_mode: 'HTML',
        reply_markup: getMainKeyboard()
    }).catch(async () => {
        // Fallback jika gagal kirim foto
        await bot.sendMessage(chatId, welcomeCaption, {
            parse_mode: 'HTML',
            reply_markup: getMainKeyboard()
        });
    });
}

module.exports = { handleStart };
