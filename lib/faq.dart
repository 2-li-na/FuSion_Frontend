import 'package:flutter/material.dart';
import 'package:fusion_new/l10n/app_localizations.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({super.key});

  List<FAQItem> _getFAQItems(AppLocalizations localizations) {
    return [
      FAQItem(
        question: localizations.faqQuestion1,
        answer: [localizations.faqAnswer1],
      ),
      FAQItem(
        question: localizations.faqQuestion2,
        answer: [localizations.faqAnswer2],
      ),
      FAQItem(
        question: localizations.faqQuestion3,
        answer: [localizations.faqAnswer3],
      ),
      FAQItem(
        question: localizations.faqQuestion4,
        answer: [localizations.faqAnswer4],
      ),
      FAQItem(
        question: localizations.faqQuestion5,
        answer: [localizations.faqAnswer5],
      ),
      FAQItem(
        question: localizations.faqQuestion6,
        answer: [localizations.faqAnswer6],
      ),
      FAQItem(
        question: localizations.faqQuestion7,
        answer: [localizations.faqAnswer7],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final faqItems = _getFAQItems(localizations);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.faq),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: faqItems.length,
        itemBuilder: (context, index) {
          return FAQTile(faqItem: faqItems[index]);
        },
      ),
      backgroundColor: Colors.green[50],
    );
  }
}

class FAQItem {
  final String question;
  final List<String> answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class FAQTile extends StatefulWidget {
  final FAQItem faqItem;

  const FAQTile({super.key, required this.faqItem});

  @override
  FAQTileState createState() => FAQTileState();
}

class FAQTileState extends State<FAQTile> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        widget.faqItem.question,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      onExpansionChanged: (isExpanded) {
        setState(() {
          widget.faqItem.isExpanded = isExpanded;
        });
      },
      initiallyExpanded: widget.faqItem.isExpanded,
      children: widget.faqItem.answer.map((paragraph) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            paragraph,
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Color.fromARGB(221, 24, 69, 36),
              height: 1.5,
            ),
          ),
        );
      }).toList(),
    );
  }
}