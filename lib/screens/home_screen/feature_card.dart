import '../../consts/consts.dart';

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          // Ensures the column takes only the required height
          child: Column(
            mainAxisSize: MainAxisSize.max, // Prevents unnecessary expansion
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: orangeColor),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Flexible(
                // Prevents text overflow
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  // overflow:
                  //     TextOverflow.ellipsis, // Adds "..." if text overflows
                  maxLines: 3, // Limits lines to prevent overflow
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
