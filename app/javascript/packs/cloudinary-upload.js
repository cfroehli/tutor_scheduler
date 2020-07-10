// Main cloudinary.js dispatch to lib or lib-es5
// depending on process.versions.node which is not
// available at runtime (e.versions.node undefined when running on heroku)
// Manually select the js for node > 8
import 'cloudinary/lib/cloudinary.js';
