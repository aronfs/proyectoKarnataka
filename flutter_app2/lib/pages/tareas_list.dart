import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app2/pages/add_page.dart';
import 'package:http/http.dart' as http;

class TareasListPage extends StatefulWidget {
  final Map? tarea;
  const TareasListPage({
    super.key,
    this.tarea
    });

  @override
  State<TareasListPage> createState() => _TareasListPageState();
}

class _TareasListPageState extends State<TareasListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchTarea();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplicacion de Tareas'),
        backgroundColor: Colors.black54,
      ),
      
      body: Visibility(
        visible: isLoading,
        child: Center(child : CircularProgressIndicator()),
      replacement: RefreshIndicator(
        onRefresh: fetchTarea,
        child: Visibility(
          visible: items.isNotEmpty,
          replacement: Center(child: Text("Sin Tareas",
          style: Theme.of(context).textTheme.headlineMedium,)),
         child: ListView.builder(
            itemCount: items.length,
            padding: EdgeInsets.all(12),
             itemBuilder: (context, index){
                final item = items[index] as Map;
                final id = item['id'] as int;
            return Card(
          child: ListTile(
            leading: CircleAvatar(child:Text('${index+1}')),
              title: Text(item['nombre_Tarea']),
               subtitle: Text(item['fecha_Tarea']),
            trailing: PopupMenuButton(
               onSelected: (value){
                  if (value == 'editar' ){
                    navigateToEditPage(item);
                  }else if(value == 'eliminar'){
                    deleteById(id);
                  }
            },
            itemBuilder: (context) {
            return[
                const PopupMenuItem(
                  child: Text('Actualizar'),
                  value: 'editar',
                  ),
                PopupMenuItem(
                  child: Text('Eliminar'),
                  value: 'eliminar',
                ),
            ];
          }),
        ),
          );
      },
      ),
        ),
      ),
      ),


      floatingActionButton: FloatingActionButton.extended(
        onPressed: navigateToAddPage, 
        label: Text('Añadir Tarea')),
    );
  }

  Future<void> navigateToEditPage(Map item) async{
    final route = MaterialPageRoute(
      builder: (context) => AddTareaPage(tarea: item),
    );
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTarea();
  }



  Future<void> navigateToAddPage() async{
    final route = MaterialPageRoute(builder: (context) => AddTareaPage(),

    );
   
    await Navigator.push(context, route);
    setState(() {
      isLoading = true;
    });
    fetchTarea();
  }

 Future<void>deleteById(int id) async{
    final url = 'https://10.0.2.2:7070/api/Tareas/$id';
    final uri = Uri.parse(url);
    
    final response = await http.delete(uri);
    if (response.statusCode == 204){
      final filtro = items.where((element) => element['id'] != id).toList();
      setState(() {
        items = filtro;
      });
    }else{
      showErrorMessage('Eliminacion Fallida');
    }
 }


  void showErrorMessage(String message){
    final snackBar = SnackBar(
      content: Text(message,
       style: const TextStyle(color: Colors.white),
       ),   
       backgroundColor: Colors.red,
      );
       ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }




  Future<void> fetchTarea() async{
   
    final url = 'https://10.0.2.2:7070/api/Tareas';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if(response.statusCode == 200){
        final json = jsonDecode(response.body);  
        final result = json as List;
        setState(() {
          items = result;
        });
    }else{
        print(response.body);
    }

    setState(() {
      isLoading = false;
    });
   
  }

}