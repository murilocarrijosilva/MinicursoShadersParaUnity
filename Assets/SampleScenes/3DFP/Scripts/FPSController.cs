using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FPSController : MonoBehaviour {

    private void Update() {
        float mouseX = Input.GetAxis("Mouse X");
        float mouseY = Input.GetAxis("Mouse Y");

        transform.Rotate(Vector3.up * mouseX);

        float movX = Input.GetAxis("Horizontal") * 0.2f;
        float movY = Input.GetAxis("Vertical") * 0.2f;

        transform.Translate(movX, 0, movY);

        //transform.LookAt(Vector3 worldposition);
    }

}
