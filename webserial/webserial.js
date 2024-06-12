const express = require('express');
// const SerialPort = require('serialport');
const { SerialPort } = require('serialport')
const { ReadlineParser } = require('@serialport/parser-readline')

const app = express();
const port = 3000;

const cors = require('cors');
app.use(cors());

// Middleware to parse JSON bodies
app.use(express.json());

// Define the serial port and baud rate
// /dev/ttyUSB0
const arduinoPort = new SerialPort({
    path: '/dev/ttyACM0',  // change to serial port of rpi either /dev/ttyUSB0 or /dev/ttyACM0
    baudRate: 9600,
    autoOpen: false
});

// Open the port
arduinoPort.open((err) => {
    if (err) {
        return console.error('Error opening port: ', err.message);
    }
    console.log('Serial port opened');
});

// Set up a parser to read lines of text from the Arduino
const parser = arduinoPort.pipe(new ReadlineParser({ delimiter: '\r\n' }));

// Endpoint to send data to the Arduino
app.post('/send', (req, res) => {
    const { message } = req.body;

    if (!message) {
        return res.status(400).send('Message is required');
    }

    arduinoPort.write(message + '\n', (err) => {
        if (err) {
            return res.status(500).send('Error writing to serial port: ' + err.message);
        }
        console.log('Message sent to Arduino: ', message);
        res.send('Message sent: ' + message);
    });
});

// Endpoint to receive data from the Arduino
app.get('/receive', (req, res) => {
    let receivedData = '';

    // Listen for data from the Arduino
    parser.once('data', (data) => {
        receivedData = data;
        console.log('Received from Arduino: ', receivedData);
        res.send('Received: ' + receivedData);
    });

    // Timeout in case no data is received
    setTimeout(() => {
        if (!receivedData) {
            res.send('No data received from Arduino');
        }
    }, 5000);  // 5 seconds timeout
});

// Start the server
app.listen(port, () => {
    console.log(`API server running at http://0.0.0.0:${port}`);
});
