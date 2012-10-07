
class SphereVisualProperties extends PropertiesView
{
  SphereVisualProperties()
    : super.fromResource('web/views/templates/sphere_visual_properties.xml')
  {
    ready.then((t) {
      t.dataContext = new SphereVisualPropertiesViewModel();
    });
  }

  String get name => 'Sphere Visual';
}
