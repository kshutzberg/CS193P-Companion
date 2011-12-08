//
//  CS193PInstructorTableViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "CS193PInstructorTableViewController.h"
#import "LecturesTableViewController.h"
#import "TopicsTableViewController.h"
#import "Entities+Create.h"
#import "QuestionSearchTableViewController.h"

@interface CS193PInstructorTableViewController()<QuestionSearchTableViewControllerDelegate>
@property (nonatomic, strong) UIManagedDocument *databaseDocument;

- (void)useDocumentWithCompletionHandler:(void (^)(UIManagedDocument *document))completion;

@end

@implementation CS193PInstructorTableViewController
@synthesize databaseDocument = _databaseDocument;


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BOOL showLectures = [segue.identifier isEqualToString:@"showLectures"];
    BOOL showTopics = [segue.identifier isEqualToString:@"showTopics"];
    
    if(showLectures || showTopics)
    {
        CoreDataTableViewController *destinationTableViewController = segue.destinationViewController;
        
        NSString *entity;
        NSArray *descriptors;
        
        //Configure destination specific attributes
        if(showLectures){
            destinationTableViewController.title = @"Lectures";
            entity = ENTITY_LECTURE;
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"lectureName" ascending:YES];
            descriptors = [NSArray arrayWithObject:nameDescriptor];
        }
        else if(showTopics){
            destinationTableViewController.title = @"Topics";
            entity = ENTITY_TOPIC;
            NSSortDescriptor *nameDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"topicName" ascending:YES];
            descriptors = [NSArray arrayWithObject:nameDescriptor];
        }
        
        //Set up the FetchedResultsController:
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
        request.sortDescriptors = descriptors;
        
        [self useDocumentWithCompletionHandler:^(UIManagedDocument *document){
            
            destinationTableViewController.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:document.managedObjectContext.parentContext sectionNameKeyPath:nil cacheName:nil]; 
            
        }];

    }
    else if([segue.identifier isEqualToString:@"showQuestionSearch"]){
        NSArray *viewControllers = [(UINavigationController *)segue.destinationViewController viewControllers];
        for (UIViewController *VC in viewControllers) {
            if ([VC isKindOfClass:[QuestionSearchTableViewController class]]) {
                QuestionSearchTableViewController *searchTVC = (QuestionSearchTableViewController *)VC;
                searchTVC.delegate = self;
                //searchTVC.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(userDidCancel)];
            }
        }
        
    }
    
}
- (IBAction)askQuestion:(id)sender {
    QuestionSearchTableViewController *searchTVC = [self.storyboard instantiateViewControllerWithIdentifier:@"searchQuestions"];
    searchTVC.delegate = self;
    [self presentModalViewController:[[UINavigationController alloc] initWithRootViewController:searchTVC] animated:YES];
}

- (void)addTestDataToDocument:(UIManagedDocument *)document
{
    //Answers {Answer 1, Answer 2, Answer 3}
    NSArray *answers = [[NSArray alloc] initWithObjects:[Answer answerWithString:@"Answer 1" inContext:document.managedObjectContext],
                        [Answer answerWithString:@"Answer 2" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 3" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 4" inContext:document.managedObjectContext],[Answer answerWithString:@"Answer 5" inContext:document.managedObjectContext], nil];
    
    //Lecture: {Lecture 1, Lecture 2, Lecture: Core Data}
    Lecture *lecture = [Lecture lectureWithName:@"Lecture 1" andNumber:1 inContext:document.managedObjectContext];
    [Lecture lectureWithName:@"Lecture 2" andNumber:2 inContext:document.managedObjectContext];
    [Lecture lectureWithName:@"Lecture: Core Data" andNumber:3 inContext:document.managedObjectContext];
    
    //Topics: {Core Data, Foundation}
    NSArray *topics = [[NSArray alloc] initWithObjects:[Topic topicWithString:@"Core Data" inContext:document.managedObjectContext], [Topic topicWithString:@"Foundation" inContext:document.managedObjectContext], nil];
    
    
    [Question questionWithName:@"Test question" andPrompt:@"What answer should I choose?" andTime:30 andAnswers:answers forLecture:lecture withTopics:topics inManagedObjectContext:self.databaseDocument.managedObjectContext];
    
    [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
}

- (void)useDocumentWithCompletionHandler:(void (^)(UIManagedDocument *document))completion
{
    if(!completion)completion = ^(UIManagedDocument *document){};
    
    //Lazily instantiate the document
    NSFileManager *manager = [NSFileManager defaultManager];
    if(!self.databaseDocument){
        NSURL *documentsURL = [[manager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
        
#define DATABASE_NAME @"datamodel"
        
        self.databaseDocument = [[UIManagedDocument alloc] initWithFileURL:[documentsURL URLByAppendingPathComponent:DATABASE_NAME]];
    }
    
    //If the file does not exist on disk, create it:
    if (![manager fileExistsAtPath:self.databaseDocument.fileURL.path]) {
        [self.databaseDocument saveToURL:self.databaseDocument.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)completion(self.databaseDocument);
            else NSLog(@"File creation failed");
        }];
    }
    
    //If the file is not open yet, open it:
    else if(self.databaseDocument.documentState == UIDocumentStateClosed){
        [self.databaseDocument openWithCompletionHandler:^(BOOL success) {
            if(success)completion(self.databaseDocument);
            else NSLog(@"Failed to open file");
            
        }];
    }
    
    else if(self.databaseDocument.documentState == UIDocumentStateNormal){
        completion(self.databaseDocument);
    }
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self useDocumentWithCompletionHandler:NULL];
    
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Question search table view delegate

-(void)userDidCancel
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//    
//    // Configure the cell...
//    
//    return cell;
//}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
