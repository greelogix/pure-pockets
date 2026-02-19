import 'package:get/get.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../utils/receipt_parser.dart';

class OcrService extends GetxService {
  final TextRecognizer _textRecognizer = TextRecognizer();
  final ImagePicker _picker = ImagePicker();
  final ReceiptParser _parser = ReceiptParser();

  Future<OcrService> init() async {
    return this;
  }

  Future<ParsedReceipt?> scanReceipt({bool fromCamera = true}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      );

      if (image == null) return null;

      // Pre-process image for better OCR accuracy
      String processedPath = await _preprocessImage(image.path);

      final inputImage = InputImage.fromFilePath(processedPath);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);

      // Use hybrid parser for structured extraction
      ParsedReceipt parsedReceipt = _parser.parse(recognizedText, processedPath);
      
      return parsedReceipt;
    } catch (e) {

      return null;
    }
  }

  Future<String?> saveToSandbox(String originalPath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'receipt_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String targetPath = '${directory.path}/$fileName';

      // Compress and save
      var result = await FlutterImageCompress.compressAndGetFile(
        originalPath,
        targetPath,
        quality: 80,
      );

      return result?.path;
    } catch (e) {

      return null;
    }
  }

  Future<String> _preprocessImage(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      img.Image? originalImage = img.decodeImage(bytes);

      if (originalImage == null) return path; // Return original if decode fails

      // 1. Convert to grayscale
      img.Image grayscaleImage = img.grayscale(originalImage);

      // 2. Enhance contrast (Simple approach using adjustColor if available, or just returning grayscale)
      // Note: 'image' package API varies by version. Using robust linear logic if possible, 
      // but simplistic grayscale is often the biggest win for OCR.
      // We will try a manual contrast adjustment if needed, but grayscale is the request.
      // Let's stick to grayscale + normalization if easy, otherwise just grayscale.
      
      // Attempting contrast enhancement
      // img.adjustColor(grayscaleImage, contrast: 1.5); // This API might not exist in all versions
      
      // Save to temp file
      final directory = await getTemporaryDirectory();
      final String fileName = 'processed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String newPath = '${directory.path}/$fileName';

      await File(newPath).writeAsBytes(img.encodeJpg(grayscaleImage, quality: 90));
      

      return newPath;
    } catch (e) {

      return path;
    }
  }

  @override
  void onClose() {
    _textRecognizer.close();
    super.onClose();
  }
}
